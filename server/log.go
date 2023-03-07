package main

import (
	"io/ioutil"
	"log"
	"os"
)

var (
	//Debug print debug informantion
	Debug *log.Logger
	//Info print Info informantion
	Info *log.Logger
	//Error print Error informantion
	Error *log.Logger
)

func init() {
	Info = log.New(os.Stdout, "[INFO] ", log.Ldate|log.Ltime)
	Error = log.New(os.Stderr, "[ERROR] ", log.Ldate|log.Ltime|log.Lshortfile)
	Debug = log.New(ioutil.Discard, "[DEBUG] ", log.Ldate|log.Ltime|log.Lshortfile)
}
