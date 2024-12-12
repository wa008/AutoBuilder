## AutoBuilder
AutoBuilder can program, build, display, update with screenshot code, what developer need to do is check and test the product of website and provide feedback to make product better.

Welcome suggestions!

## Products by AutoBuilder

[LocalTools](https://github.com/wa008/LocalTools)

## How to use

Supported platform
- [x] MacOS
- [ ] Windows
- [ ] Linux

Steps
+ target: Write your project description into `./prompts/targets.txt`
+ key: Write `API_KEY` into `.env` file if you use openai model
+ Chrome: open Chrome and visit `http://localhost:8000/`
+ Start: Open terminal, run `sh run.sh`
    + program, build, display(automatic): It will generator code based on your project description and build, display it on Chrome
    + Feedback(manual): Test the result of code on Chrome and write feedback into terminal, press `enter` in last step, till result is perfect.
+ deploy: github pages

## FAQ
Q: When you need this project?

A: When you want to realize a small project, like a simple static website, it'a suitable for you.


Q: What is the difference with copilot or cursor?

A: This project makes building, displaying, getting and uploading screenshot automatic, which can save lots of time when you want to build a small website.

## What used
+ OpenAI API / Ollama
+ Apple script: get screenshot, open and refresh chrome
+ Python
+ Shell 
