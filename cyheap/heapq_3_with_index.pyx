# -*- coding: latin-1 -*-

"""Heap queue algorithm (a.k.a. priority queue).

Heaps are arrays for which a[k] <= a[2*k+1] and a[k] <= a[2*k+2] for
all k, counting elements from 0.  For the sake of comparison,
non-existing elements are considered to be infinite.  The interesting
property of a heap is that a[0] is always its smallest element.

Usage:

heap = []            # creates an empty heap
heappush(heap, item) # pushes a new item on the heap
item = heappop(heap) # pops the smallest item from the heap
item = heap[0]       # smallest item on the heap without popping it
heapify(x)           # transforms list into a heap, in-place, in linear time
item = heapreplace(heap, item) # pops and returns smallest item, and adds
                               # new item; the heap size is unchanged

Our API differs from textbook heap algorithms as follows:

- We use 0-based indexing.  This makes the relationship between the
  index for a node and the indexes for its children slightly less
  obvious, but is more suitable since Python uses 0-based indexing.

- Our heappop() method returns the smallest item, not the largest.

These two make it possible to view the heap as a regular Python list
without surprises: heap[0] is the smallest item, and heap.sort()
maintains the heap invariant!
"""

# Original code by Kevin O'Connor, augmented by Tim Peters and Raymond Hettinger

__about__ = """Heap queues

[explanation by Fran�ois Pinard]

Heaps are arrays for which a[k] <= a[2*k+1] and a[k] <= a[2*k+2] for
all k, counting elements from 0.  For the sake of comparison,
non-existing elements are considered to be infinite.  The interesting
property of a heap is that a[0] is always its smallest element.

The strange invariant above is meant to be an efficient memory
representation for a tournament.  The numbers below are `k', not a[k]:

                                   0

                  1                                 2

          3               4                5               6

      7       8       9       10      11      12      13      14

    15 16   17 18   19 20   21 22   23 24   25 26   27 28   29 30


In the tree above, each cell `k' is topping `2*k+1' and `2*k+2'.  In
a usual binary tournament we see in sports, each cell is the winner
over the two cells it tops, and we can trace the winner down the tree
to see all opponents s/he had.  However, in many computer applications
of such tournaments, we do not need to trace the history of a winner.
To be more memory efficient, when a winner is promoted, we try to
replace it by something else at a lower level, and the rule becomes
that a cell and the two cells it tops contain three different items,
but the top cell "wins" over the two topped cells.

If this heap invariant is protected at all time, index 0 is clearly
the overall winner.  The simplest algorithmic way to remove it and
find the "next" winner is to move some loser (let's say cell 30 in the
diagram above) into the 0 position, and then percolate this new 0 down
the tree, exchanging values, until the invariant is re-established.
This is clearly logarithmic on the total number of items in the tree.
By iterating over all items, you get an O(n ln n) sort.

A nice feature of this sort is that you can efficiently insert new
items while the sort is going on, provided that the inserted items are
not "better" than the last 0'th element you extracted.  This is
especially useful in simulation contexts, where the tree holds all
incoming events, and the "win" condition means the smallest scheduled
time.  When an event schedule other events for execution, they are
scheduled into the future, so they can easily go into the heap.  So, a
heap is a good structure for implementing schedulers (this is what I
used for my MIDI sequencer :-).

Various structures for implementing schedulers have been extensively
studied, and heaps are good for this, as they are reasonably speedy,
the speed is almost constant, and the worst case is not much different
than the average case.  However, there are other representations which
are more efficient overall, yet the worst cases might be terrible.

Heaps are also very useful in big disk sorts.  You most probably all
know that a big sort implies producing "runs" (which are pre-sorted
sequences, which size is usually related to the amount of CPU memory),
followed by a merging passes for these runs, which merging is often
very cleverly organised[1].  It is very important that the initial
sort produces the longest runs possible.  Tournaments are a good way
to that.  If, using all the memory available to hold a tournament, you
replace and percolate items that happen to fit the current run, you'll
produce runs which are twice the size of the memory for random input,
and much better for input fuzzily ordered.

Moreover, if you output the 0'th item on disk and get an input which
may not fit in the current tournament (because the value "wins" over
the last output value), it cannot fit in the heap, so the size of the
heap decreases.  The freed memory could be cleverly reused immediately
for progressively building a second heap, which grows at exactly the
same rate the first heap is melting.  When the first heap completely
vanishes, you switch heaps and start a new run.  Clever and quite
effective!

In a word, heaps are useful memory structures to know.  I use them in
a few applications, and I think it is good to keep a `heap' module
around. :-)

--------------------
[1] The disk balancing algorithms which are current, nowadays, are
more annoying than clever, and this is a consequence of the seeking
capabilities of the disks.  On devices which cannot seek, like big
tape drives, the story was quite different, and one had to be very
clever to ensure (far in advance) that each tape movement will be the
most effective possible (that is, will best participate at
"progressing" the merge).  Some tapes were even able to read
backwards, and this was also used to avoid the rewinding time.
Believe me, real good tape sorts were quite spectacular to watch!
From all times, sorting has always been a Great Art! :-)
"""

__all__ = ['heappush2', 'heappop2', 'heappop_arbitrary', 'heapify2', 'heapreplace2',
            'heappushpop2']

from itertools import islice, count,  tee, chain
from operator import itemgetter

def cmp_lt(x, y):
    # Use __lt__ if available; otherwise, try __le__.
    # In Py3.x, only __lt__ will be called.
    return (x < y) if hasattr(x, '__lt__') else (not y <= x)

def get_key(item):
    if hasattr(item, 'get_key'):
        return item.get_key()
    else:
        return item

def heappush2(heap, item, heapIndex):
    """Push item onto heap, maintaining the heap invariant."""
    if get_key(item) in heapIndex:
        raise Exception("Duplicated item")
    heapIndex[get_key(item)] = len(heap)
    heap.append(item)
    _siftdown(heap, 0, len(heap)-1, heapIndex)

def heappop2(heap, heapIndex):
    """Pop the smallest item off the heap, maintaining the heap invariant."""
    lastelt = heap.pop()    # raises appropriate IndexError if heap is empty
    if heap:
        returnitem = heap[0]
        heap[0] = lastelt
        _siftup(heap, 0, heapIndex)
    else:
        returnitem = lastelt
    del heapIndex[get_key(returnitem)]
    return returnitem

def heappop_arbitrary_if_existent(heap, heapIndex, key):
    if key in heapIndex:
        heappop_arbitrary(heap, heapIndex, key)

def heappop_arbitrary(heap, heapIndex, key):
    assert len(heap) == len(heapIndex)
    
    if heap:
        elementIndex = heapIndex[key]
        if elementIndex == 0:
            return heappop2(heap, heapIndex)
        else:
            if elementIndex == len(heap)-1:
                del heapIndex[key]
                return heap.pop(len(heap)-1)
            else:
                retElement = heap[elementIndex]
                del heapIndex[key]
                heap[elementIndex] = heap[len(heap)-1]
                heapIndex[get_key(heap[elementIndex])] = elementIndex
                heap.pop(len(heap)-1) #remove last element
                _siftdown(heap, elementIndex, len(heap)-1, heapIndex)
                if elementIndex == heapIndex[get_key(heap[elementIndex])]:
                    _siftup(heap, elementIndex, heapIndex)
                return retElement
    else:
        raise Exception("Poping empty heap")

def changeHeapElement(heap, keyOld, itemNew, heapIndex):

    if keyOld != get_key(itemNew) and get_key(itemNew) in heapIndex:
        raise Exception("Duplicate item in heap")
    elementIndex = heapIndex[keyOld]
    itemOld = heap[elementIndex]
    heap[elementIndex] = itemNew
    del heapIndex[keyOld]
    heapIndex[get_key(itemNew)] = elementIndex
    if cmp_lt(itemOld, itemNew):
        _siftup(heap, elementIndex, heapIndex)
    else:
        _siftdown(heap, 0, elementIndex, heapIndex)

#use after having changed the priority insed the item
def decreasedPriority(heap, key, heapIndex):
    elementIndex = heapIndex[key]
    _siftup(heap, elementIndex, heapIndex)

#use after having changed the priority insed the item
def increasedPriority(heap, key, heapIndex):
    elementIndex = heapIndex[key]
    _siftdown(heap, 0, elementIndex, heapIndex)

def heapreplace2(heap, item, heapIndex):
    """Pop and return the current smallest value, and add the new item.

    This is more efficient than heappop() followed by heappush(), and can be
    more appropriate when using a fixed-size heap.  Note that the value
    returned may be larger than item!  That constrains reasonable uses of
    this routine unless written as part of a conditional replacement:

        if item > heap[0]:
            item = heapreplace(heap, item)
    """
    returnitem = heap[0]    # raises appropriate IndexError if heap is empty
    del heapIndex[get_key(returnitem)]
    heapIndex[get_key(item)] = 0
    heap[0] = item
    _siftup(heap, 0, heapIndex)
    return returnitem

def heappushpop2(heap, item, heapIndex):
    """Fast version of a heappush followed by a heappop."""
    if heap and cmp_lt(heap[0], item):
        return heapreplace2(heap, item, heapIndex)
    return item

def peek_arbitrary(heap, key, heapIndex):
    if key not in heapIndex:
        return None
    return heap[heapIndex[key]]


def heapify2(heap, heapIndex):

    for i in range(len(heap)):
        heapIndex[get_key(heap[i])] = i
    """Transform list into a heap, in-place, in O(len(x)) time."""
    n = len(heap)
    # Transform bottom-up.  The largest index there's any point to looking at
    # is the largest with a child index in-range, so must have 2*i + 1 < n,
    # or i < (n-1)/2.  If n is even = 2*j, this is (2*j-1)/2 = j-1/2 so
    # j-1 is the largest, which is n//2 - 1.  If n is odd = 2*j+1, this is
    # (2*j+1-1)/2 = j so j-1 is the largest, and that's again n//2-1.
    for i in reversed(range(n//2)):
        _siftup(heap, i, heapIndex)

# 'heap' is a heap at all indices >= startpos, except possibly for pos.  pos
# is the index of a leaf with a possibly out-of-order value.  Restore the
# heap invariant.
def _siftdown(heap, startpos, pos, heapIndex):
    newitem = heap[pos]
    # Follow the path to the root, moving parents down until finding a place
    # newitem fits.
    while pos > startpos:
        parentpos = (pos - 1) >> 1
        parent = heap[parentpos]
        if cmp_lt(newitem, parent):
            heap[pos] = parent
            heapIndex[get_key(parent)] = pos
            pos = parentpos
            continue
        break
    heap[pos] = newitem
    heapIndex[get_key(newitem)] = pos

# The child indices of heap index pos are already heaps, and we want to make
# a heap at index pos too.  We do this by bubbling the smaller child of
# pos up (and so on with that child's children, etc) until hitting a leaf,
# then using _siftdown to move the oddball originally at index pos into place.
#
# We *could* break out of the loop as soon as we find a pos where newitem <=
# both its children, but turns out that's not a good idea, and despite that
# many books write the algorithm that way.  During a heap pop, the last array
# element is sifted in, and that tends to be large, so that comparing it
# against values starting from the root usually doesn't pay (= usually doesn't
# get us out of the loop early).  See Knuth, Volume 3, where this is
# explained and quantified in an exercise.
#
# Cutting the # of comparisons is important, since these routines have no
# way to extract "the priority" from an array element, so that intelligence
# is likely to be hiding in custom __cmp__ methods, or in array elements
# storing (priority, record) tuples.  Comparisons are thus potentially
# expensive.
#
# On random arrays of length 1000, making this change cut the number of
# comparisons made by heapify() a little, and those made by exhaustive
# heappop() a lot, in accord with theory.  Here are typical results from 3
# runs (3 just to demonstrate how small the variance is):
#
# Compares needed by heapify     Compares needed by 1000 heappops
# --------------------------     --------------------------------
# 1837 cut to 1663               14996 cut to 8680
# 1855 cut to 1659               14966 cut to 8678
# 1847 cut to 1660               15024 cut to 8703
#
# Building the heap by using heappush() 1000 times instead required
# 2198, 2148, and 2219 compares:  heapify() is more efficient, when
# you can use it.
#
# The total compares needed by list.sort() on the same lists were 8627,
# 8627, and 8632 (this should be compared to the sum of heapify() and
# heappop() compares):  list.sort() is (unsurprisingly!) more efficient
# for sorting.

def _siftup(heap, pos, heapIndex):
    endpos = len(heap)
    startpos = pos
    newitem = heap[pos]
    # Bubble up the smaller child until hitting a leaf.
    childpos = 2*pos + 1    # leftmost child position
    while childpos < endpos:
        # Set childpos to index of smaller child.
        rightpos = childpos + 1
        if rightpos < endpos and not cmp_lt(heap[childpos], heap[rightpos]):
            childpos = rightpos
        # Move the smaller child up.
        heap[pos] = heap[childpos]
        heapIndex[get_key(heap[childpos])] = pos
        pos = childpos
        childpos = 2*pos + 1
    # The leaf at pos is empty now.  Put newitem there, and bubble it up
    # to its final resting place (by sifting its parents down).
    heap[pos] = newitem
    heapIndex[get_key(heap[pos])] = pos
    _siftdown(heap, startpos, pos, heapIndex)

def is_heap(heap, k):
    l = len(heap)
    if l == 0:
        return True
    if 2 * k + 1 < l and heap[k] > heap[2 * k + 1]:
        xx = heap[k] > heap[2 * k + 1]
        return False
    if 2 * k + 2 < l and heap[k] > heap[2 * k + 2]:
        return False
    if 2 * k + 1 < l and not is_heap(heap, 2 * k + 1):
        return False
    if 2 * k + 2 < l and not is_heap(heap, 2 * k + 2):
        return False
    return True

def check_heap(heap):
    if not is_heap(heap, 0):
        raise Exception("Not a heap")

def check_indexed_heap(heap, heapIndex):
    if not is_heap(heap, 0):
        raise Exception("Not a heap")
    if len(heapIndex) != len(heap):
        raise Exception("Heap and index have different sizes")
    for key, itemIndex in heapIndex.items():
        item = heap[itemIndex]
        if key != get_key(item):
            raise Exception("Index and heap don't match")

def heap_prune(heap, max_len):
    """Discard items in the queue if the queue is longer than the beam."""
    if len(heap) > max_len:
        del heap[:max_len]


def indexed_heap_prune(heap, max_len, heapIndex):
    if len(heap) > max_len:
        for item in heap[max_len]:
            del heapIndex[get_key(item)]
        del heap[:max_len]


class IndexedHeapExampleElement:

    def __init__(self, key, priority, value):
       self._key = key
       self._priority = priority
       self._value = value

    def __lt__(self, other):
       return self._priority < other._priority

    def get_key(self):
        return self._key

    def __str__(self):
        return self.__repr__()

    def __repr__(self):
        return str(self._key) + " " + str(self._priority) + " " + str(self._value)

if __name__ == "__main__":
    # Simple sanity test
    heap = []
    data = [1, 3, 5, 7, 9, 2, 4, 6, 8, 0]
    heapIndex = dict()
    check_indexed_heap(heap, heapIndex)
    for item in data:
        heappush2(heap, item, heapIndex)
        check_indexed_heap(heap, heapIndex)
    

    print("heap      "+str(heap))
    print("heapIndex:"+str(heapIndex))
    
    heappop2(heap, heapIndex)
    print("after pop")
    print("heap:     "+str(heap))
    print("heapIndex:"+str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heappop2(heap, heapIndex)
    print("after pop")
    print("heap:     "+str(heap))
    print("heapIndex:"+str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    #remove item 9
    heappop_arbitrary(heap, heapIndex, 9)
    print("after removing item 9")
    print("heap:     "+str(heap))
    print("heapIndex:"+str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heappop_arbitrary(heap, heapIndex, 7)
    print("after removing item 7")
    print("heap:     "+str(heap))
    print("heapIndex:"+str(heapIndex))
    check_indexed_heap(heap, heapIndex)


    sort = []
    while heap:
        sort.append(heappop2(heap, heapIndex))
    print(sort)

    print("______________________________")
    # Class sanity test
    heap = []
    data = [1, 3, 5, 7, 9, 2, 4, 6, 8, 0]
    heapIndex = dict()
    check_indexed_heap(heap, heapIndex)
    for item in data:
        heappush2(heap, IndexedHeapExampleElement(item, -item, item*item), heapIndex)
        check_indexed_heap(heap, heapIndex)

    data2 = [IndexedHeapExampleElement(item, -item, item*item) for item in data]

    print("heap      " + str(heap))
    print("heapIndex:" + str(heapIndex))

    heappop2(heap, heapIndex)
    print("after pop")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heappop2(heap, heapIndex)
    print("after pop")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    # remove item 1
    heappop_arbitrary(heap, heapIndex, 1)
    print("after removing item 1")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heappop_arbitrary(heap, heapIndex, 2)
    print("after removing item 1")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    changeHeapElement(heap, 3, IndexedHeapExampleElement(11, -11, 11*11), heapIndex)
    print("after replacing item 3 by 11")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heap[heapIndex[6]]._priority = -66
    increasedPriority(heap, 6, heapIndex)
    print("after increasing 6 priority")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heap[heapIndex[5]]._priority = 10
    decreasedPriority(heap, 5, heapIndex)
    print("after increasing 6 priority")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    changeHeapElement(heap, 7, IndexedHeapExampleElement(7, -77, 49), heapIndex)
    print("after replacing 7")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    changeHeapElement(heap, 11, IndexedHeapExampleElement(11, 111, 121), heapIndex)
    print("after replacing 11")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)


    sort = []
    while heap:
        sort.append(heappop2(heap, heapIndex))
    print(sort)

    print("Not a heap  :", str(data2))
    heapIndex2 = {}
    heapify2(data2, heapIndex2)
    print("heap:     " + str(data2))
    print("heapIndex:" + str(heapIndex2))
    check_indexed_heap(data2, heapIndex2)
    #import doctest
    #doctest.testmod()
