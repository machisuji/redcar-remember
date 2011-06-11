
Plugin.define do
  name    "remember"
  version "1.0"
  file    "lib", "remember"
  object  "Redcar::Remember"
  dependencies "redcar", ">0",
               "application", ">0",
               "project", ">=1.1"
end