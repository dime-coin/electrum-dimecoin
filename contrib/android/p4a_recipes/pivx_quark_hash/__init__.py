from pythonforandroid.recipe import CythonRecipe


class PivxQuarkHashRecipe(CythonRecipe):

    url = ('https://github.com/dime-coin/'
           'dime_quark_hash/archive/refs/tags/{version}.tar.gz')
    sha256sum = '89e591df61d861f5d557b61e66f57fda13034bcda7bbc505981fb9fd431ee5bb'
    version = '1.2'
    depends = ['python3', 'wheel', 'setuptools']


recipe = PivxQuarkHashRecipe()

