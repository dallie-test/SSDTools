import os
import subprocess


def git_version():
    """
    Return the git revision as a string.

    :return: git revision.
    :rtype str
    """

    def _minimal_ext_cmd(cmd):
        # construct minimal environment
        env = {}
        for k in ['SYSTEMROOT', 'PATH', 'HOME']:
            v = os.environ.get(k)
            if v is not None:
                env[k] = v
        # LANGUAGE is used on win32
        env['LANGUAGE'] = 'C'
        env['LANG'] = 'C'
        env['LC_ALL'] = 'C'

        # Set the working directory
        cwd = os.path.dirname(os.path.abspath(__file__))

        return subprocess.Popen(cmd, stdout=subprocess.PIPE, env=env, cwd=cwd).communicate()[0]

    try:
        out = _minimal_ext_cmd(['git', 'rev-parse', 'HEAD'])
        GIT_REVISION = out.strip().decode('ascii')
    except OSError:
        GIT_REVISION = "Unknown"

    return GIT_REVISION


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
