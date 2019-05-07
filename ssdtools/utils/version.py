def git_version():
    """
    Return the git revision as a string.

    :return: git revision.
    :rtype str
    """

    return "Unknown"


def get_version(version=None):
    """
    Return a version number from VERSION.

    :parameter tuple version: specification of the version.
    :rtype: str
    """

    version = get_complete_version(version)

    # Now build the two parts of the version number:
    # main = X.Y[.Z]
    # sub = .dev+N - for development releases

    main = get_main_version(version)

    sub = ''
    if version[3] == 'dev' and version[4] == 0:
        git_revision = git_version()
        if git_revision:
            sub = '.dev+%s' % git_revision[:7]

    return main + sub


def get_main_version(version=None):
    """

    Return main version (X.Y[.Z]) from VERSION.

    :parameter tuple version: specification of the version.
    :return: main version (X.Y[.Z])
    :rtype str
    """
    version = get_complete_version(version)
    parts = 2 if version[2] == 0 else 3
    return '.'.join(str(x) for x in version[:parts])


def get_complete_version(version=None):
    """
    Return a tuple of the django version. If version argument is non-empty,
    check for correctness of the tuple provided.

    :parameter tuple version: specification of the version.
    :return: version specification.
    :rtype tuple
    """
    if version is None:
        from ssdtools import VERSION as version
    else:
        assert len(version) == 5
        assert version[3] in ('dev', 'final')

    return version
