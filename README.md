# Docker-образ для использования DeepSpeech
Этот образ специально подготовлен для быстрого старта в создании русскоязычной tensorflow-модели, ориентированной на решение задачи Speech To Text в контексте управления умным домом.

## Установка

```
sudo -s
curl -sSL https://get.docker.com | sh
docker run -it --name deepspeech -v /home/deepspeech:/work cutecare/deepspeech:latest bash
```

## Создание модели

Все дальнейшие команды выполняются внутри контейнера.
Создаем языковую модель на основе языкового корпуса, составленного из страниц русскоязычной [Wikipedia](https://sites.google.com/site/rmyeid/projects/polyglot).

```
cd /home/DeepSpeech/kenlm/build
wget -O ru_wiki_text.tar.lzma "http://projectscloud.ru/tags/ru_wiki_text.tar.lzma"
tar xfv ru_wiki_text.tar.lzma
bin/lmplz -o 4 -S 3G <ru/full.txt | bin/build_binary /dev/stdin /work/lm.binary 
```

Создаем trie-структуру, необходимую для дальнейшего обучения сети. В качестве параметров используется русский алфавит, языковая модель, полученная на предыдущем шаге и словарь, состоящий из фраз, релевантных контексту.

```
cd /home/DeepSpeech
git pull
native_client/generate_trie data/alphabet.txt /work/lm.binary data/lm/vocab.txt /work/trie
```

Для обучения сети нам нужны учебные данные - звуковые файлы и их транскрибация. Сообществом VoxForge подготовлен огромный материал, но общего контекста. Если позволяют вычислительные мощности, то лучше конечно воспользоваться этими данными.

```
cd /home/DeepSpeech
chmod 775 *
./bin/import_voxforge.py /home/DeepSpeech/data
./DeepSpeech.py --train_files data/voxforge-train.csv --dev_files data/voxforge-dev.csv --test_files data/cutecare/voxforge.csv --checkpoint_dir /work/checkpoint --export_dir /work/export --lm_binary_path /work/lm.binary --lm_trie_path /work/trie
```

Чтобы опробовать все на тестовых данных, используйте наш учебный материал. Работать с ним можно на виртуальной машине. Обучение сети займет всего пару суток.

```
cd /home/DeepSpeech
chmod 775 bin/*
nohup ./bin/run-cutecare.sh &
```

### Ссылки
https://github.com/cutecare/DeepSpeech

https://research-journal.org/technical/sravnitelnyj-analiz-sistem-raspoznavaniya-rechi-s-otkrytym-kodom/

http://kheafield.com/code/kenlm/

https://sites.google.com/site/rmyeid/projects/polyglot

https://github.com/Kyubyong/wordvectors
