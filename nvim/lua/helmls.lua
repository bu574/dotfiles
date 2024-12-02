require'lspconfig'.helm_ls.setup{
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true
            }
        }
    },
    cmd = { "helm_ls", "serve" },
    filetypes = { "helm" },

}
