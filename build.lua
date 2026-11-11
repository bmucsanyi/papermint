module = "papermint"

sourcefiledir = "tex/latex/papermint"
sourcefiles = { "*.sty" }
installfiles = { "*.sty" }
unpackfiles = { }

local engines = {
  "lualatex",
  "xelatex",
  "pdflatex",
}

-- Each test with the engines that compile it.
local tests = {
  { name = "papermint-check", engines = engines },
  { name = "paper-stack-check", engines = engines },
  -- The bold math version under pdflatex, where stix2 has no bold font for
  -- five of its shapes.
  { name = "bold-operator-check", engines = { "pdflatex" } },
}

-- Documents that load the math font package themselves must stop.
local error_tests = {
  {
    name = "papermint-unicode-math-error-check",
    engines = { "lualatex", "xelatex" },
    needle = "Package papermint Error: Papermint must load unicode-math itself",
  },
  {
    name = "papermint-stix2-error-check",
    engines = { "pdflatex" },
    needle = "Package papermint Error: Papermint must load stix2 itself",
  },
}

-- Glyphs with their fonts, as \tracingoutput writes the page contents to the
-- pdflatex logs.
local font_checks = {
  -- \bx is bold italic; \bTheta, \bAlpha, and \bzero are bold upright.
  { "paper-stack-check", {
    "\\LS1/stix2/b/it/10 x",
    "\\LS1/stix2/b/n/10 ^^B",
    "\\LS1/stix2/b/n/10 A",
    "\\LS1/stix2/b/n/10 0",
  } },
  -- Inside \bm, the sum comes from the medium extension font and the
  -- integral from the medium integrals font at every size, which are the
  -- shapes LaTeX substituted with a warning before papermint declared the
  -- substitution, and the letters are bold italic.
  { "bold-operator-check", {
    "\\LS2/stix2ex/m/n/10 ",
    "\\LS2/stix2cal/m/n/10 ",
    "\\LS2/stix2ex/m/n/9 ",
    "\\LS2/stix2cal/m/n/12 ",
    "\\LS1/stix2/b/it/10 x",
    "\\LS1/stix2/b/it/7.5 i",
    "\\LS1/stix2/b/it/7.5 n",
    "\\LS1/stix2/b/it/9 x",
    "\\LS1/stix2/b/it/12 y",
  } },
}

local function check(harness)
  local environment = {
    TEXINPUTS = harness.texinputs({
      "./tex/latex/papermint",
      harness.require_sibling("macromint"),
    }),
  }

  for _, test in ipairs(tests) do
    for _, engine in ipairs(test.engines) do
      if harness.compile_test(environment, test.name, engine) ~= 0 then
        return 1
      end
    end
  end

  for _, test in ipairs(error_tests) do
    for _, engine in ipairs(test.engines) do
      if harness.compile_error_test(environment, test.name, engine, test.needle) ~= 0 then
        return 1
      end
    end
  end

  for _, font_check in ipairs(font_checks) do
    local log = harness.output(font_check[1], "pdflatex", "log")
    for _, needle in ipairs(font_check[2]) do
      if not harness.file_contains(log, needle) then
        print(log .. ": missing " .. needle)
        return 1
      end
    end
  end

  for _, test in ipairs(tests) do
    for _, engine in ipairs(test.engines) do
      if harness.scan_log(harness.output(test.name, engine, "log")) ~= 0 then
        return 1
      end
    end
  end

  return 0
end

target_list.check.func = function()
  local path = "../figmint/harness.lua"
  local harness = loadfile(path)
  if not harness then
    print(path .. " is missing: the tests need a checkout of figmint next to this repository")
    return 1
  end
  return check(harness())
end
