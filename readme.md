Python heapq with dictionary of value : item impelemntation
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
    print(heapIndex)
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

Star the repo if you can use it.