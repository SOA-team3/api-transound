from pydub import AudioSegment
import speech_recognition as sr
import tempfile
import os
from googletrans import Translator
import sys

# Concurrency method
import threading

def audio_to_text(file_path):
    recognizer = sr.Recognizer()
    with sr.AudioFile(file_path) as source:
        audio_data = recognizer.record(source)

    lang = 'en'
    text = recognizer.recognize_google(audio_data, language=lang)
    return text

# Get Ruby Input
mp3_file_path = sys.stdin.read()
# mp3_file_path = "app/domain/audio_datas/data_storage/audio_test_data/"
# mp3_file_name = "These Tiny Pollinators Can Travel Surprisingly Huge Distances.mp3"
mp3_file_path = mp3_file_path.split('\n')[0]

# 將MP3文件轉換成 AudioSegment 對象
audio = AudioSegment.from_file(mp3_file_path, format="mp3")

# 設定每個片段的長度（秒）
segment_length_sec = 15

# 計算片段數量
total_segments = len(audio) // (segment_length_sec * 1000)

# 對每個片段進行並行/並發處理
TEXT = ''
def audio_segment_to_TEXT(i):
    global audio
    global segment_length_sec
    global TEXT

    start_time = i * segment_length_sec * 1000
    end_time = min((i + 1) * segment_length_sec * 1000, len(audio))
    segment = audio[start_time:end_time]

    # 將AudioSegment對象暫存為臨時檔案
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    # temp_file_path = f"app/domain/audio_datas/data_storage/audio_test_data/split_wavs{temp_file.name}"
    temp_file_path = temp_file.name
    segment.export(temp_file_path, format="wav")
    temp_file.close()

    # 進行語音轉文字
    text_result = audio_to_text(temp_file_path)
    # print(f"Segment {i + 1}: {text_result}")
    TEXT += text_result + ' '

    # 刪除臨時檔案
    os.remove(temp_file_path)

# Multi-threading
t_list = []
for i in range(total_segments):
    audio_segment_to_TEXT(i)
    t_list.append(
    threading.Thread(target=audio_segment_to_TEXT, args=(i, )))
    t_list[i].start()
for i in t_list:
    i.join()

# Translate the text
def text_translate(text, translate_language):
    translator = Translator()
    trans_lang = translate_language #'en'
    translated_text = translator.translate(text, dest=trans_lang)
    return translated_text.text
output = text_translate(TEXT, translate_language = 'en')
print(output)
# chi_output = text_translate(TEXT, translate_language = 'zh-tw')
# print(f"eng_output:\n{output}\n")
# print(f"chi_output:\n{chi_output}")
