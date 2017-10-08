
class Obj:
    """
    Returns object with same structure as dict
    """
    def __init__(self, dic):
        for k, v in dic.items():
            if isinstance(v, dict):
                self.__dict__[k] = Obj(v)
            else:
                self.__dict__[k] = v

class ObjOneLevel:
    """
    Returns object with same structure as dict
    """
    def __init__(self, dic):
        for k, v in dic.items():
            self.__dict__[k] = v
