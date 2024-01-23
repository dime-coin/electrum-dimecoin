from pythonforandroid.recipe import CythonRecipe


class PivxQuarkHashRecipe(CythonRecipe):

    url = ('https://files.pythonhosted.org/packages/'
           '42/d0/c231b69d4deda7c8f3513f92042488a043e83a443f3b878011a3fe5af870/pivx_quark_hash-{version}.tar.gz')
    sha256sum = '4ccaf9567e1fdb2ff0bf5ffaae038dfc45942daa6b7b1a3a72a34d22ecae2171'
    version = '1.2'
    depends = ['python3', 'wheel', 'setuptools']


recipe = PivxQuarkHashRecipe()