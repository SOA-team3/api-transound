import whisper
# import ffmpeg
# import ffmpeg.transcribe as whisper
# import ffmpeg-python

model = whisper.load_model("tiny") # "medium"
transcribe_l = 'jp'
options = whisper.DecodingOptions(language = transcribe_l)

# Read the stdin from Ruby
audio_file_path = "podcast_mp3_store/YUYUの日本語Podcast Vol.233 【仕事のこと】それは仕事？仕事ごっこ？(YUYU Japanese Podcast).mp3"# sys.stdin.read()

# Apply to Whisper Model
result = model.transcribe(audio_file_path)

print(result["text"])