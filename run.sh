#!/bin/bash
source ~/.bash_profile

# preparation
project_target=$(cat './prompts/targets.txt')
update_code_hint=$(cat './prompts/update_code_hint.txt')
backup_code_path="./websites_code_backup"
current_code_path="./websites_code"
model_platform="openai" # openai, ollama, zz_openai

ensure_directory_exists() {
    local directory_path=""
    if [ ! -d "$1" ]; then
        mkdir -p "$1"  
    fi
}
ensure_directory_exists "./screenshot"

# build and display page
ensure_directory_exists "$current_code_path"
cd $current_code_path
nohup python3 -m http.server & >> nohup.out
osascript ./../apple_script/open_chrome.scpy

max_iterations=10
for ((counter=1; counter<=max_iterations; counter++)); do
    echo "Iteration: $counter"

    # get feedback as input
    while true; do
        read -e -p "Please input your feedback(one line input): " feedback
        if [[ "$feedback" == "" || "$feedback" == " " ]]; then
            echo "Invalid input: $feedback"
        elif [[ ${#feedback} -lt 3 ]]; then
            echo "Too short input: $feedback"
        else
            echo "Valid input: $feedback"
            break
        fi
    done
    echo "$feedback" >> ./../feedback_log
    
    # get screenshot
    timestamp=$(date "+%Y-%m%d-%H%M%S")
    screenshotName="screenshot/GoogleChromeScreenshot_${timestamp}.png"
    osascript ./../apple_script/screenshot.scpy "../$screenshotName"
    osascript ./../apple_script/open_terminal.scpy
    pkill -f "http.server"
    cd ./../

    # update code
    ensure_directory_exists "$backup_code_path"
    rm -r $backup_code_path
    mv $current_code_path $backup_code_path
    ensure_directory_exists "$current_code_path"
    python3 ./update_code.py \
        --output_path $current_code_path \
        --attached_code_path $backup_code_path \
        --model_platform $model_platform \
        --screenshot_file $screenshotName \
        --feedback "$feedback" \
        --update_code_hint "$update_code_hint" \
        --project_target "$project_target"
    
    # build and display page
    cd $current_code_path
    nohup python3 -m http.server & >> nohup.out
    osascript ./../apple_script/open_chrome.scpy
    echo "\n\n"
done
