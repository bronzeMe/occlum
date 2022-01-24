package main

import (   
    "fmt"
	"github.com/tecbot/gorocksdb"
)

func main() {
	
	// using gorocksdb connect the RocksDB
	bbto := gorocksdb.NewDefaultBlockBasedTableOptions()
	bbto.SetBlockCache(gorocksdb.NewLRUCache(3 << 30))
	opts := gorocksdb.NewDefaultOptions()
	opts.SetBlockBasedTableFactory(bbto)
	opts.SetCreateIfMissing(true)
	// open a test database directory
	db, _ := gorocksdb.OpenDb(opts, "./db")
	
	// 
	ro := gorocksdb.NewDefaultReadOptions()
	wo := gorocksdb.NewDefaultWriteOptions()
	//  set key as 'foo' value as 'bar'
	_ = db.Put(wo, []byte("foo"), []byte("bar"))
	// get the 'foo' (key)'s value
	value, _ := db.Get(ro, []byte("foo"))	
	defer value.Free()
	// print the value
    fmt.Println("value: ", string(value.Data()[:]))
   	// delete 'foo'
	_ = db.Delete(wo, []byte("foo"))
}
