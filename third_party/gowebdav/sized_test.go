package gowebdav

import (
	"net/http"
	"testing"
)

func TestParseContentLength(t *testing.T) {
	tests := []struct {
		name    string
		setCL   string
		want    int64
		setCLFn func(http.Header)
	}{
		{"present", "1024", 1024, nil},
		{"absent", "", -1, nil},
		{"unparsable", "abc", -1, nil},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp := &http.Response{Header: http.Header{}}
			if tt.setCL != "" {
				resp.Header.Set("Content-Length", tt.setCL)
			}
			got := parseContentLength(resp)
			if got != tt.want {
				t.Errorf("got %d, want %d", got, tt.want)
			}
		})
	}
}

func TestParseTotalSizeFromRange(t *testing.T) {
	tests := []struct {
		name string
		cr   string
		want int64
	}{
		{"full range", "bytes 0-99/500", 500},
		{"mid range", "bytes 100-199/500", 500},
		{"large file", "bytes 0-999999/10000000", 10000000},
		{"absent", "", -1},
		{"malformed", "bytes 0-99", -1},
		{"unparsable total", "bytes 0-99/abc", -1},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp := &http.Response{Header: http.Header{}}
			if tt.cr != "" {
				resp.Header.Set("Content-Range", tt.cr)
			}
			got := parseTotalSizeFromRange(resp)
			if got != tt.want {
				t.Errorf("got %d, want %d", got, tt.want)
			}
		})
	}
}
