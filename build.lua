module = "papermint"

sourcefiledir = "tex/latex/papermint"
sourcefiles = { "*.sty" }
installfiles = { "*.sty" }
unpackfiles = { }
testfiledir = "testfiles"
checkengines = { "luatex", "xetex", "pdftex" }

local engines = {
  "lualatex",
  "xelatex",
  "pdflatex",
}

local log_needles = {
  "Missing character",
  "Fatal error",
  "Undefined control sequence",
  "LaTeX Error",
  "Could not resolve font",
  "Emergency stop",
  "LaTeX Warning:",
  "LaTeX Font Warning:",
  "Overfull \\hbox",
  "Overfull \\vbox",
  "Underfull \\hbox",
  "Underfull \\vbox",
}

local log_allowed = {
  "Font shape `LS2/stix2ex/b/n'",
  "Font shape `LS1/stix2bb/b/n'",
  "Font shape `LS1/stix2bb/b/it'",
  "Font shape `LS2/stix2cal/b/n'",
  "Font shape `LS2/stix2tt/b/n'",
}

local log_allowed_paths = {
  ["build/papermint-check-pdflatex.log"] = true,
  ["build/paper-stack-check-pdflatex.log"] = true,
}

local fontspec_log_allowed_paths = {
  ["build/papermint-check-lualatex.log"] = true,
  ["build/papermint-check-xelatex.log"] = true,
  ["build/paper-stack-check-lualatex.log"] = true,
  ["build/paper-stack-check-xelatex.log"] = true,
}

local fontspec_log_allowed = {
  "Could not resolve font \"STIX Two Math/B\"",
}

local standard_tests = {
  "papermint-check",
  "paper-stack-check",
}

local function quote(value)
  return "'" .. string.gsub(value, "'", "'\\''") .. "'"
end

local function run(label, command)
  print(label)
  local result = os.execute(command)
  if result == true or result == 0 then
    return 0
  end
  return 1
end

local function file_contains(path, needle)
  local handle = io.open(path, "r")
  if not handle then
    return false
  end
  local content = handle:read("*a")
  handle:close()
  return string.find(content, needle, 1, true) ~= nil
end

local function line_has_log_problem(path, line)
  if log_allowed_paths[path]
      and string.match(line, "^LaTeX Font Warning:") then
    for _, allowed in ipairs(log_allowed) do
      if string.find(line, allowed, 1, true) then
        return false
      end
    end
  end
  if fontspec_log_allowed_paths[path]
      and string.match(line, "^%(fontspec%)%s+") then
    for _, allowed in ipairs(fontspec_log_allowed) do
      if string.find(line, allowed, 1, true) then
        return false
      end
    end
  end

  if string.sub(line, 1, 1) == "!" then
    return true
  end
  if string.match(line, "^Package .+ Error") then
    return true
  end
  if string.match(line, "^Package .+ Warning:") then
    return true
  end
  if string.match(line, "^Class .+ Error") then
    return true
  end
  if string.match(line, "^Class .+ Warning:") then
    return true
  end
  for _, needle in ipairs(log_needles) do
    if string.find(line, needle, 1, true) then
      return true
    end
  end
  return false
end

local function scan_log(path)
  for line in io.lines(path) do
    if line_has_log_problem(path, line) then
      print(path .. ": " .. line)
      return 1
    end
  end
  return 0
end

local function texinputs()
  return table.concat({
    "./tex/latex/papermint",
    "../macromint/tex/latex/macromint",
    "",
  }, ":")
end

local function compile_test(name, engine_name)
  local command = "env TEXINPUTS=" .. quote(texinputs())
    .. " TEXMFVAR=" .. quote("build/texmf-var")
    .. " TEXMFCACHE=" .. quote("build/texmf-var")
    .. " " .. engine_name
    .. " -halt-on-error -interaction=nonstopmode"
    .. " -jobname=" .. quote(name .. "-" .. engine_name)
    .. " -output-directory=build"
    .. " " .. quote("testfiles/" .. name .. ".tex")

  if run(engine_name .. " " .. name, command) ~= 0 then
    return 1
  end
  return run(engine_name .. " " .. name, command)
end

local function compile_error_test(name, engine_name, needle)
  local command = "env TEXINPUTS=" .. quote(texinputs())
    .. " TEXMFVAR=" .. quote("build/texmf-var")
    .. " TEXMFCACHE=" .. quote("build/texmf-var")
    .. " " .. engine_name
    .. " -halt-on-error -interaction=nonstopmode"
    .. " -jobname=" .. quote(name .. "-" .. engine_name)
    .. " -output-directory=build"
    .. " " .. quote("testfiles/" .. name .. ".tex")

  if run(engine_name .. " " .. name .. " expected error", command) == 0 then
    print(name .. ": expected TeX error did not occur")
    return 1
  end

  local log_path = "build/" .. name .. "-" .. engine_name .. ".log"
  if not file_contains(log_path, needle) then
    print(log_path .. ": missing expected error text")
    return 1
  end
  return 0
end

local function papermint_check()
  if run("create build directory", "mkdir -p build/texmf-var") ~= 0 then
    return 1
  end

  for _, engine in ipairs(engines) do
    for _, test in ipairs(standard_tests) do
      if compile_test(test, engine) ~= 0 then
        return 1
      end
    end
  end

  local unicode_math_error =
    "Package papermint Error: Papermint must load unicode-math itself"
  for _, engine in ipairs({ "lualatex", "xelatex" }) do
    if compile_error_test("papermint-unicode-math-error-check", engine, unicode_math_error) ~= 0 then
      return 1
    end
  end

  local stix2_error =
    "Package papermint Error: Papermint must load stix2 itself"
  if compile_error_test("papermint-stix2-error-check", "pdflatex", stix2_error) ~= 0 then
    return 1
  end

  for _, engine in ipairs(engines) do
    for _, test in ipairs(standard_tests) do
      if scan_log("build/" .. test .. "-" .. engine .. ".log") ~= 0 then
        return 1
      end
    end
  end

  return 0
end

target_list.check.func = function()
  return papermint_check()
end
