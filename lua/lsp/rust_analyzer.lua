-- spec: https://rust-analyzer.github.io/manual.html#configuration

return {
    enabled = true,
    lspconfig = {
        filetypes = {
            "rust",
        },
        cmd = { "rust-analyzer", },
        single_file_support = true,
        settings = {
            ["rust-analyzer"] = {
                inlayHints = {
                    chainingHints = {
                        enable = false,
                    },
                    parameterHints = {
                        enable = false,
                    },
                    typeHints = {
                        enable = false,
                    },
                },
                --[[ assist = {
                    emitMustUse = false,
                    expressionFillDefault = false,
                },
                cachePriming = {
                    enable = false,
                },
                cargo = {
                    autoreload = false,
                    buildScripts = {
                        enable = false,
                    },
                },
                checkOnSave = false,
                completion = {
                    autoimport = {
                        enable = false,
                    },
                    autoself = {
                        enable = false,
                    },
                    callable = {
                        snippets = false,
                    },
                    fullFunctionSignatures = {
                        enable = false,
                    },
                    postfix = {
                        enable = false,
                    },
                    privateEditable = {
                        enable = false,
                    },
                },
                diagnostics = {
                    enable = false,
                },
                highlightRelated = {
                    breakPoints = {
                        enable = false,
                    },
                    closureCaptures = {
                        enable = false,
                    },
                    exitPoints = {
                        enable = false,
                    },
                    references = {
                        enable = false,
                    },
                    yieldPoints = {
                        enable = false,
                    },
                },
                hover = {
                    actions = {
                        enable = false,
                    },
                    documentation = {
                        enable = true,
                    },
                    links = {
                        enable = false,
                    },
                    memoryLayout = {
                        enable = false,
                    },
                },
                imports = {
                    group = {
                        enable = false,
                    },
                },
                inlayHints = {
                    bindingModeHints = {
                        enable = false,
                    },
                    chainingHints = {
                        enable = false,
                    },
                    closingBraceHints = {
                        enable = false,
                    },
                    closureCaptureHints = {
                        enable = false,
                    },
                    closureReturnTypeHints = {
                        enable = false,
                    },
                    discriminantHints = {
                        enable = false,
                    },
                    expressionAdjustmentHints = {
                        enable = false,
                    },
                    lifetimeElisionHints = {
                        enable = false,
                    },
                    parameterHints = {
                        enable = false,
                    },
                    reborrowHints = {
                        enable = false,
                    },
                    typeHints = {
                        enable = false,
                    },
                },
                joinLines = {
                    joinAssignments = false,
                    joinElseIf = false,
                    removeTrailingComma = false,
                    unwrapTrivialBlock = false,
                },
                lens = {
                    enable = false,
                },
                notifications = {
                    cargoTomlNotFound = false,
                },
                procMacro = {
                    enable = false,
                },
                references = {
                    excludeImports = false,
                },
                rustfmt = {
                    rangeFormatting = {
                        enable = false,
                    },
                },
                semanticHighlighting = {
                    doc = {
                        comment = {
                            inject = {
                                enable = false,
                            },
                        },
                    },
                    nonStandardTokens = false,
                    operator = {
                        enable = false,
                    },
                    punctuation = {
                        enable = false,
                    },
                    strings = {
                        enable = false,
                    },
                },
                signatureInfo = {
                    documentation = {
                        enable = true,
                    },
                },
                typing = {
                    autoClosingAngleBrackets = {
                        enable = false,
                    },
                }, ]]
            },
        },
    },
}
