# Docker-образ для использования DeepSpeech
Этот образ специально подготовлен для быстрого старта в создании русскоязычной tensorflow-модели, ориентированной на решение задачи Speech To Text в контексте управления умным домом.

## Установка

```
sudo -s
curl -sSL https://get.docker.com | sh
docker run -d --name deepspeech -v /etc/localtime:/etc/localtime:ro cutecare/deepspeech:latest
```

## Создание модели

Подключаемся к консоли контейнера:

```
docker exec -it deepspeech bash
```

Все дальнейшие команды выполняются внутри контейнера.
Создаем языковую модель на основе языкового корпуса, составленного из страниц русскоязычной [Wikipedia](https://sites.google.com/site/rmyeid/projects/polyglot).

```
cd /home/DeepSpeech/kenlm/build
wget -O ru_wiki_text.tar.lzma "https://downloader.disk.yandex.ru/disk/71f9226562099a2e7d51a15b78a7d72ed4c9052588315def745afb7a7d277d86/5a7e225e/xzO90AcS2RgzBLTfJiTsV9neJ0q43FWsJSXsgud43YCOFRMCRmmtDYBJcn_E0I_J7RSe9OXaONmMF06O9g37Vw%3D%3D?uid=0&filename=ru_wiki_text.tar.lzma&disposition=attachment&hash=llBBd/Rpfnkib2pBeYHtaaEMNenYWAOlKMop2ZNevjM%3D%3A&limit=0&content_type=application%2Foctet-stream&fsize=550737536&hid=20432b814a39232d37e389d6c057da46&media_type=compressed&tknv=v2"
tar --lzma xfv ru_wiki_text.tar.lzma
bin/lmplz -o 4 -S 3G <ru/full.txt | bin/build_binary /dev/stdin /home/DeepSpeech/data/lm/lm.binary 
```

Создаем trie-структуру, необходимую для дальнейшего обучения сети. В качестве параметров используется русский алфавит, языковая модель, полученная на предыдущем шаге и словарь, состоящий из фраз, релевантных контексту.

```
cd /home/DeepSpeech
native_client/generate_trie data/alphabet.txt data/lm/lm.binary data/lm/vocab.txt data/lm/trie
```

Для обучения сети нам нужны учебные данные - звуковые файлы и их транскрибация. Сообществом VoxForge подготовлен огромный материал, но общего контекста. Если позволяют вычислительные мощности, то лучше конечно воспользоваться этими данными.

```
cd /home/DeepSpeech
chmod 775 *
./bin/import_voxforge.py /home/DeepSpeech/data
./DeepSpeech.py --train_files data/voxforge-train.csv --dev_files data/voxforge-dev.csv --test_files data/cutecare/voxforge.csv --checkpoint_dir data/checkpoint --export_dir data/export
```

Чтобы опробовать все на тестовых данных, используйте наш учебный материал. Работать с ним можно на виртуальной машине. Обучение сети займет всего пару суток.

```
cd /home/DeepSpeech
chmod 775 *
./DeepSpeech.py --train_files data/cutecare/cutecare-train.csv --dev_files data/cutecare/cutecare-dev.csv --test_files data/cutecare/cutecare-test.csv --checkpoint_dir data/checkpoint --export_dir data/export
```

### Ссылки
https://research-journal.org/technical/sravnitelnyj-analiz-sistem-raspoznavaniya-rechi-s-otkrytym-kodom/
http://kheafield.com/code/kenlm/
https://sites.google.com/site/rmyeid/projects/polyglot
https://github.com/Kyubyong/wordvectors
