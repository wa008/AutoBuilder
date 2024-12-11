
import sys
import json
import requests
import base64
import argparse
import os
from dotenv import load_dotenv
load_dotenv()

parser = argparse.ArgumentParser(description="Process some arguments.")
parser.add_argument("--project_target", help="Target project identifier or path to process", required=True)
parser.add_argument("--update_code_hint", help="Hint or flag indicating the need to update the code", required=True)
parser.add_argument("--backup_path", help="Path to the attached code file or directory", required=True)
parser.add_argument("--output_path", help="Destination path to save the generated output", required=True)
parser.add_argument("--model_platform", help="Platform or framework for the model being used", required=True)
parser.add_argument("--screenshot_file", help="File path to the screenshot for processing or reference", required=True)
parser.add_argument("--feedback", help="Feedback message or data related to the project", required=True)
parser.add_argument("--model", help="model to request", required=True)
args = parser.parse_args()

if args.model_platform == 'ollama':
    import ollama

def merge_files_with_filenames(directory_path):
    """
    Merges the contents of all files in a directory, appending each filename to its content.

    Args:
        directory_path (str): Path to the directory containing the files.

    Returns:
        str: A single string with filenames and their respective contents merged.
    """
    if not os.path.isdir(directory_path):
        raise ValueError(f"The provided path '{directory_path}' is not a valid directory.")
    
    merged_content = []
    
    for filename in os.listdir(directory_path):
        if filename == 'nohup.out': continue
        file_path = os.path.join(directory_path, filename)
        if os.path.isfile(file_path):  # Ensure it's a file
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
                merged_content.append(f"Filename: {filename}\n{content}\n")
    
    return "\n".join(merged_content)


def request(input_prompt, model_platform):
    if model_platform == 'ollama':
        return ollama_request(input_prompt)
    elif model_platform == 'openai':
        return openai_request(input_prompt)
    elif model_platform == 'zz_openai':
        return zz_openai_request(input_prompt)
    else:
        print ('error')

def openai_request(input_prompt):
   api_key = os.environ['OPENAI_API_KEY']
   with open(args.screenshot_file, "rb") as img_file:
      img_b64_str = base64.b64encode(img_file.read()).decode("utf-8")
   url = "https://api.openai.com/v1/chat/completions"
   payload_raw = {
      "model": args.model,
      "messages": [
         {
            "role": "user",
            "content": [
               {
                  "type": "text",
                  "text": input_prompt
               },
               {
                  "type": "image_url",
                  "image_url": {
                     "url":  f"data:image/jpeg;base64,{img_b64_str}"
                  }
               }
            ]
         }
      ]
   }
   payload = json.dumps(payload_raw)
   headers = {
      'Content-Type': 'application/json',
      'Authorization': f"Bearer {api_key}"
   }
   response = requests.request("POST", url, headers=headers, data=payload)
   output_content = response.json()['choices'][0]['message']['content']
   return output_content

def zz_openai_request(input_prompt):
   api_key = os.environ['ZZ_OPENAI_API_KEY']
   with open(args.screenshot_file, "rb") as img_file:
      img_b64_str = base64.b64encode(img_file.read()).decode("utf-8")
   url = "https://xiaoai.plus/v1/chat/completions"
   payload_raw = {
      "model": args.model,
      "messages": [
         {
            "role": "user",
            "content": [
               {
                  "type": "text",
                  "text": input_prompt
               },
               {
                  "type": "image_url",
                  "image_url": {
                     "url":  f"data:image/jpeg;base64,{img_b64_str}"
                  }
               }
            ]
         }
      ]
   }
   payload = json.dumps(payload_raw)
   headers = {
      'Content-Type': 'application/json',
      'Authorization': api_key
   }
   response = requests.request("POST", url, headers=headers, data=payload)
   output_content = response.json()['choices'][0]['message']['content']
   return output_content

def ollama_request(input_prompt):
   res = ollama.chat(
      model = args.model,
      messages=[
         {
            'role': 'user',
            'content': input_prompt, 
            'images': [args.screenshot_file]
         }
      ]
   )
   output_content = res['message']['content']
   return output_content


def main():
   merged_code_string = merge_files_with_filenames(args.backup_path)
   input_prompt = f"{args.project_target}\n\nBased on current code and result, {args.feedback}\n\n{args.update_code_hint}\n\nCurrent code:\n{merged_code_string}"
   # print("print_input_prompt", input_prompt)

   output_content = request(input_prompt, args.model_platform)
   # print ("print_output_content: ", output_content)

   multi_code_file = output_content.split("-------------------")
   # print (f"direct answer from AI: {multi_code_file[0]}")
   for one_line in multi_code_file[1: ]:
      one_line = one_line.strip('\n').split("\n")
      if len(one_line) < 2: continue

      filename = one_line[0].strip('*')
      code = "\n".join(one_line[1: ])
      # rows = len(code.split('\n'))
      # print (f"filename: {filename}, row: {rows}")

      # write response in output file 
      with open(args.output_path + "/" + filename, 'w') as f:
         f.write(code)

if __name__ == "__main__":
	main()
