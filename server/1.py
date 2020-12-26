from gtts import gTTS
i = 0
while i<=9:
    tts = gTTS(str(i), lang='zh-tw')
    tts.save(str(i)+'.mp3')
    i = i+1
