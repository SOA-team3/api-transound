from bs4 import BeautifulSoup
import requests
import re

episode_url = 'https://podcasts.apple.com/tw/podcast/the-intelligence-embedded-in-gaza/id151230264?i=1000633839389'

page = requests.get(episode_url)

soup = BeautifulSoup(page.text, features="html.parser")
html_string = soup.prettify()
pattern = r'assetUrl\\":\\"(.*?)\\"'
podcast_url = re.findall(pattern, html_string)[0]

print(f'{podcast_url} {episode_url}')