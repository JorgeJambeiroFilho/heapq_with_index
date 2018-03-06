Python heapq with dictionary of value : item implementation
=======================================

Currently only implemented for ```heappop()``` and ```heappush()``` (renamed ```heappop2(), heappush2()``` ) 
and added method ```heappop_arbitrary()```

Example use:
```
    # Simple sanity test
    heap = []
    data = [1, 3, 5, 7, 9, 2, 4, 6, 8, 0]
    heapIndex = dict()
    for item in data:
        heappush2(heap, item, heapIndex)
    
    print("heap      "+str(heap))
    print("heapIndex:"+str(heapIndex))

    heappop2(heap, heapIndex)
    print("after pop")
    print("heap:     "+str(heap))
    print("heapIndex:"+str(heapIndex))
    
    #remove item 3
    heappop_arbitrary(heap, heapIndex, 9)
    print("after removing item 9")
    print("heap:     "+str(heap))
    print("heapIndex:"+str(heapIndex))
```

output:
```
heap      [0, 1, 2, 6, 3, 5, 4, 7, 8, 9]
heapIndex:{0: 0, 1: 1, 2: 2, 3: 4, 4: 6, 5: 5, 6: 3, 7: 7, 8: 8, 9: 9}
after pop
heap:     [1, 3, 2, 6, 9, 5, 4, 7, 8]
heapIndex:{1: 0, 2: 2, 3: 1, 4: 6, 5: 5, 6: 3, 7: 7, 8: 8, 9: 4}
heapIndex item:4
after removing item 9
heap:     [1, 3, 2, 6, 5, 4, 7, 8]
heapIndex:{1: 0, 2: 2, 3: 1, 4: 6, 5: 5, 6: 3, 7: 7, 8: 8}
```


Star the repo if you can use it.