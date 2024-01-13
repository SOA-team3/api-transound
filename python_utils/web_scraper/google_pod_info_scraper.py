import requests
from bs4 import BeautifulSoup
import wget # to download files
import pandas as pd
import os


def download_podcasts_info(soup, title):
    i = 0
    time_l = []
    ID_l = []
    description_l = []
    length_l = []
    link_l = []
    name_l = []
    for podcast in soup.find_all('a', {'role':'listitem'}):
        # print(f'{podcast}\n\n\n')
        time = podcast.find('div', {'class':'OTz6ee'}).text
        if (time.startswith('Dec') or time.startswith('Nov')) and (time.endswith('2020')):
        # if True:
            i += 1
            time_l.append(time)

            html = podcast.get('href')
            print(f'html: {html}')

            link = podcast.find('div', {'jsname':'fvi9Ef'})['jsdata'].split(';')[1]
            link_l.append(link)

            name = podcast.find('div', {'class':'e3ZUqe'}).text
            name_l.append(name)

            # ID is just the filename for later access
            print(i, ":", time)
            # filename = wget.download(link, out=title)
            # os.rename(filename, title+'/audio'+str(i)+'.mp3') # use if the downloaded name is always the same
            ID_l.append('audio'+str(i))
            # ID_l.append(str(i))

            try: # sometimes there's no description
                description = podcast.find('div', {'class':'LrApYe'}).text
            except:
                description = 'None'
            if description is None:
                description = 'None'
            description_l.append(description)

            length = podcast.find('span', {'class':'gUJ0Wc'}).text
            length_l.append(length)

    df = pd.DataFrame(list(zip([title]*len(ID_l), ID_l, name_l, time_l, description_l, length_l, link_l)),
                      columns =['Show', 'ID', 'Episode', 'Time', 'Description', 'Length', 'Link'])
    return df

stack_overflow_pod_url = 'https://podcasts.google.com/feed/aHR0cHM6Ly9mZWVkcy5zaW1wbGVjYXN0LmNvbS9YQV84NTFrMw?sa=X&ved=0CAkQlvsGahcKEwjwqt2f9u3vAhUAAAAAHQAAAAAQAQ'
URLs = [stack_overflow_pod_url]
info_df_list = []
for url in URLs:
    soup = BeautifulSoup(requests.get(url).text, 'lxml')
    title = soup.find('div', {'class':'ZfMIwb'}).text # This is the name of the show

    # make a new folder to contain podcasts from the same show
    if not os.path.exists(f'app/domain/audio_datas/data_storage/{title}'):
        os.mkdir(f'app/domain/audio_datas/data_storage/{title}')
    else:
        print(f"The folder '{title}' already exists.")

    df = download_podcasts_info(soup, title) # function details below
    info_df_list.append(df)
print(info_df_list)
# info_all_podcasts = pd.concat(info_df_list)