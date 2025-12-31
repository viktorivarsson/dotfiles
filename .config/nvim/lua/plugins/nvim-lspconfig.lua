local util = require("lspconfig.util")

return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    servers = {
      svelte = {},
      oxlint = {},
      denols = {
        root_dir = util.root_pattern("deno.json", "deno.jsonc"),
      },
      tsgo = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            if result.diagnostics == nil then
              return
            end

            -- ignore some diagnostics
            local idx = 1
            while idx <= #result.diagnostics do
              local entry = result.diagnostics[idx]

              local formatter = require("format-ts-errors")[entry.code]
              entry.message = formatter and formatter(entry.message) or entry.message

              -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
              if entry.code == 80001 then
                -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
                table.remove(result.diagnostics, idx)
              else
                idx = idx + 1
              end
            end

            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
          end,
        },
      },
    },
  },
}
