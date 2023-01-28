from cyheap.heapq_3_with_index import check_indexed_heap
from cyheap.heapq_3_with_index import heappush2
from cyheap.heapq_3_with_index import heappop2
from cyheap.heapq_3_with_index import heappop_arbitrary
from cyheap.heapq_3_with_index import IndexedHeapExampleElement
from cyheap.heapq_3_with_index import increasedPriority
from cyheap.heapq_3_with_index import decreasedPriority
from cyheap.heapq_3_with_index import changeHeapElement
from cyheap.heapq_3_with_index import  heapify2

if __name__ == "__main__":
    # Simple sanity test
    heap = []
    data = [1, 3, 5, 7, 9, 2, 4, 6, 8, 0]
    heapIndex = dict()
    check_indexed_heap(heap, heapIndex)
    for item in data:
        heappush2(heap, item, heapIndex)
        check_indexed_heap(heap, heapIndex)

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

    # remove item 9
    heappop_arbitrary(heap, heapIndex, 9)
    print("after removing item 9")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
    check_indexed_heap(heap, heapIndex)

    heappop_arbitrary(heap, heapIndex, 7)
    print("after removing item 7")
    print("heap:     " + str(heap))
    print("heapIndex:" + str(heapIndex))
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
        heappush2(heap, IndexedHeapExampleElement(item, -item, item * item), heapIndex)
        check_indexed_heap(heap, heapIndex)

    data2 = [IndexedHeapExampleElement(item, -item, item * item) for item in data]

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

    changeHeapElement(heap, 3, IndexedHeapExampleElement(11, -11, 11 * 11), heapIndex)
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
    # import doctest
    # doctest.testmod()
