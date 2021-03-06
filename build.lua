#!/usr/bin/env texlua

-- Build script for "beamer" files

-- Identify the bundle and module
bundle = ""
module = "beamer"

-- Non-standard structure
docfiledir    = "./doc"
sourcefiledir = "./base"

-- Install all files from the source tree directly
installfiles = {"**/*.cls", "**/*.sty", "**/beamericon*.*"}
sourcefiles  = installfiles
unpackfiles  = { }

-- Typeset only the main documentation file,
-- but make all sources available
docfiles     =
  {
    "**/*.jpg", 
    "**/*.tex",
    "**/*.txt",
    "**/beamerlogo.pdf",
    "**/beamerexample-lecture-logo.pdf"
  }
typesetfiles = 
  {
    "beameruserguide.tex",
    "beamerexample-conference-talk.tex",
    "beamerexample-lecture-beamer-version.tex",
    "beamerexample-lecture-print-version.tex"
  }

-- Only copy Markdown files to main dir
textfiles = {"*.md"}

-- Custom clean-up settings
cleanfiles = {"beameruserguide.pdf", "*.zip"}

-- Test set up
checkengines   = {"pdftex"}
checksuppfiles = {"*.tex"}

-- Use standard MakeIndex style
indexstyle = ""

-- Auto-versioning
versionfiles = {"beamer.cls", "beamerarticle.sty", "beameruserguide.tex"}
function setversion_update_line(line, date, version)
  local date = string.gsub(date, "%-", "/")
  if string.match(line, "^  %[%d%d%d%d/%d%d/%d%d v%d%.%d+ ") then
    line = string.gsub(line, "%d%d%d%d/%d%d/%d%d", date)
    line = string.gsub(line, "v%d%.%d+ ", "v" .. version .. " ")
  end
  if string.match(line, "\\def\\beamerugversion") then
    line = string.gsub(line, "%d%.%d+", version)
  end
  return line
end

-- Release a TDS-style zip
packtdszip = true

-- Preserve structure for CTAN
flatten = false

-- Custom data for the theme demos
themes =
  {
    core = 
      {
        "AnnArbor", "Antibes", "Berkeley", "Berlin", "Bergen", "Boadilla",
        "Copenhagen", "Darmstadt", "Dresden", "EastLansing", "Frankfurt",
        "Goettingen", "Hannover", "Ilmenau", "JuanLesPins", "Luebeck",
        "Malmoe", "Madrid", "Marburg", "Montpellier", "PaloAlto",
        "Pittsburgh", "Rochester", "Singapore", "Szeged", "Warsaw",
        "CambridgeUS", "default", "boxes"
      },
    font = 
      {
        "default", "serif", "structurebold", "structureitalicserif",
        "structuresmallcapsserif"
      },
    color =
      {
        "default", "crane", "albatross", "seahorse", "whale", "dolphin",
        "rose", "orchid", "sidebartab", "lily", "structure", "dove", "seagull",
        "beetle", "fly", "wolverine", "spruce", "beaver", "monarca",
        "albatrossstylish" -- This is a special case: see the .tex file
      },
    outer =
      {
        "default", "infolines", "miniframes", "shadow", "sidebar",
        "smoothbars", "smoothtree", "split", "tree"
      },
    inner = {"default", "circles", "rectangles", "rounded", "inmargin"}
  }

function typeset_demo_tasks()
  local errorlevel = 0
  for type,themelist in pairs(themes) do
    local themetype = ""
    if  type~= "core" then themetype = tostring(type) end
    local name = "beamer" .. themetype .. "themeexample.tex"
    for _,theme in pairs(themelist) do
      errorlevel = errorlevel + runtool(
        "", ".",
        "TEXINPUTS",
        "pdflatex \\def\\themename{" .. theme .. "}"
          .. "\\input " .. name .. " "
      )
      if errorlevel ~= 0 then
        return errorlevel
      end
      ren(typesetdir,
        string.gsub(name, "%.tex$", ".pdf"),
        "beamerug" .. themetype .. "theme" .. theme .. ".pdf")
    end
  end
  return 0
end

-- Find and run the build system
kpse.set_program_name("kpsewhich")
dofile(kpse.lookup("l3build.lua"))
