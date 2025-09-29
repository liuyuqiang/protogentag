package module_test

import (
	"bytes"
	"os"
	"testing"

	"github.com/liuyuqiang/protogentag/module"
	pgs "github.com/lyft/protoc-gen-star/v2"
	"github.com/spf13/afero"
)

func TestExtract(t *testing.T) {
	req, err := os.Open("../debug/code_generator_request.pb.bin")
	if err != nil {
		t.Fatal(err)
	}

	fs := afero.NewMemMapFs()
	res := &bytes.Buffer{}

	pgs.Init(
		pgs.ProtocInput(req),
		pgs.ProtocOutput(res),
		pgs.FileSystem(fs),
	).RegisterModule(module.New()).Render()
}
