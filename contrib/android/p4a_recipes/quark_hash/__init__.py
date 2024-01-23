from pythonforandroid.recipe import CythonRecipe


class QuarkHashRecipe(CythonRecipe):

    url = ('https://files.pythonhosted.org/packages/'
           'eb/96/15811e69038f075ce34e6b610e5a44ff279ed14a3b0ffb2948dd3fde177a/quark_hash-{version}.tar.gz')
    sha256sum = 'eb1de478ff1acf810f50d3e227532a937252006eb124afb3da248baaa559b7d4'
    version = '1.0'
    depends = ['python3', 'wheel', 'setuptools']


recipe = QuarkHashRecipe()