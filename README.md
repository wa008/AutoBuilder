## AutoBuilder
AutoBuilder can help you to build static websites automatically. It can program, build, display, update with screen shot, what developer need to do is check and test the product of website and provide feedback to make product better.

Example:


This is my side project, welcome advce. 

## How to use
Steps
+ Write your project description into `./prompts/targets.txt`
+ Write `API_KEY` into `.env` file
+ open Chrome and visit `http://localhost:8000/`
+ Open terminal, run `sh run.sh`, it will generator code based on your project description and build, display it on Chrome
+ Test the result of code on Chrome and write feedback into terminal, press `enter` in last step, till the result is perfect.

## What I used
+ OpenAI API / Ollama
+ Apple script: get screenshot, open and refresh chrome
+ Python
+ Shell 