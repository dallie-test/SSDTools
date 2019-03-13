class Grid(object):
    def __init__(self, data=None, info=None):
        """

        :param np.ndarray data: grid data
        :param dict info: grid information
        """
        if data is not None:
            self.data = data
        if info is not None:
            self.info = info

    @classmethod
    def from_envira_file(cls, path):
        """

        :param str path:
        """
        pass

    @classmethod
    def from_envira_files(cls, paths):
        """

        :param list(str) paths:
        """
        pass

    def to_envira(self, path):
        """

        :param str path:
        """
        pass
