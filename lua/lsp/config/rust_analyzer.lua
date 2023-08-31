--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

return {
    cmd = { 'rust-analyzer' },
    settings = {
        -- https://github.com/rust-lang/rust-analyzer/blob/master/docs/user/generated_config.adoc
        ['rust-analyzer'] = {
            cargo = {
                -- Extra environment variables that will be set when running cargo, rustc
                -- or other commands within the workspace. Useful for setting RUSTFLAGS.
                extraEnv = {
                    OPENSSL_INCLUDE_DIR = '/usr/include/openssl-1.0/',
                    OPENSSL_LIB_DIR = '/usr/lib/openssl-1.0/'
                }
            }
            --[[ inlayHints = {
                    closingBraceHints = {
                        -- Whether to show inlay hints after a closing `}` to indicate what item it belongs to.
                        enable = false
                    },
                } ]]
        }
    }
}
