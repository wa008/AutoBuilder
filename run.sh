#!/bin/bash
source ~/.bash_profile

model_platform="openai"
current_project_path="current_project"
while [[ $# -gt 0 ]]; do
    case $1 in
        --model_platform)
            model_platform="$2"
            shift 2
            ;;
        --project)
            current_project_path="$2"
            shift 2
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

if [[ "$model_platform" == "openai" ]]; then
    model="gpt-4o"
elif [[ "$model_platform" == "ollama" ]]; then
    model="llava:13b"
else 
    echo "Error: '--model_platform' parameter is unsupported"
    exit 1
fi

if [[ -z "$current_project_path" ]]; then
    echo "Error: '--path' parameter is missing or empty."
    exit 1
fi

echo "model_platform: $model_platform"
echo "project: $current_project_path"

# preparation
project_target=$(cat './prompts/targets.txt')
update_code_hint=$(cat './prompts/update_code_hint.txt')
backup_project_path="${current_project_path}_backup"

ensure_directory_exists() {
    local directory_path=""
    if [ ! -d "$1" ]; then
        mkdir -p "$1"  
    fi
}
ensure_directory_exists "./screenshot"

# build and display page
ensure_directory_exists "$current_project_path"
cd $current_project_path
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
    ensure_directory_exists "$backup_project_path"
    rm -r $backup_project_path
    mv $current_project_path $backup_project_path
    ensure_directory_exists "$current_project_path"
    python3 ./update_code.py \
        --output_path $current_project_path \
        --backup_path $backup_project_path \
        --model_platform $model_platform \
        --model $model \
        --screenshot_file $screenshotName \
        --feedback "$feedback" \
        --update_code_hint "$update_code_hint" \
        --project_target "$project_target"
    
    # build and display page
    cd $current_project_path
    nohup python3 -m http.server & >> nohup.out
    osascript ./../apple_script/open_chrome.scpy
    echo "\n\n"
done
