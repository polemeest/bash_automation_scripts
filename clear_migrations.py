""" модуль для django, предназначенный для удаления файлов миграций"""
import os
import argparse

try:
    from config.settings import BASE_DIR
except ImportError:
    print("Can't find path to BASE DIR.")
    BASE_DIR = os.getcwd()


def clear_all_migrations(additional_path: str) -> None:
    '''
    Чистит все папки миграций от файлов миграций, кроме инициализатора и
    кэша. Если приложения держатся в отдельной папке, принимает аргумент
    дополнительной папки.
    '''
    try:
        base_dir = os.path.join(BASE_DIR, additional_path)
    except NameError:
        base_dir = os.path.join(input('Введите путь до начальной папки'),
                                additional_path)
    except ValueError:
        print(ValueError('недопустимое значение для base_dir'))
        return clear_all_migrations()

    for item in os.listdir(base_dir):
        path = os.path.join(base_dir, item)
        if os.path.isdir(path):
            if str(item) == 'migrations':
                for file in os.listdir(path):
                    if not str(file).startswith("__"):
                        os.remove(os.path.join(path, file))
                        print('INFO: removed ' +
                              "\\".join(path.split("\\")[-2:]) + '\\' + file)
            else:
                clear_all_migrations(path)
    return


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='Django ORM migrations remover.',
        description='type -p to input custom folder to your apps',
        epilog="apps is a default value")
    parser.add_argument('-p', '--path', type=str, help='Path to process')
    add_path = parser.parse_args().path

    if not add_path:
        add_path = "apps"
    clear_all_migrations(add_path)
    print('SUCCESS: УСПЕШНО ЗАВЕРШЕНО')
