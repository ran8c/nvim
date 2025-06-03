vim.bo.equalprg = "gofmt -s"
vim.bo.makeprg = "{ go vet && staticcheck && go build }"
