from functools import reduce # Python 3


def get_object_key(obj, key, default=None):
    def get_key(obj, key):
        try:
            return obj[key]
        except (KeyError, TypeError):
            return default
    return reduce(get_key, key.split('/'), obj)


if __name__ == "__main__":
    object = {'a': {'b': {'c': 'd'}}}
    key = 'a/b/c'
    value = get_object_key(object, key)
    print(f"Object {object} retrieved key {key} value is {value}")
    """
    >>> Object {'a': {'b': {'c': 'd'}}} retrieved key a/b/c value is d
    """
