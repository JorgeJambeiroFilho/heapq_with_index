import Cython.Compiler.Options
import setuptools
from Cython.Build import cythonize

Cython.Compiler.Options.annotate = True

setuptools.setup(name="heapq_3_c_with_index",
                 ext_modules=cythonize("heapq_3_with_index.pyx", annotate=True, compiler_directives={'language_level' : "3"} ),
                 include_dirs=[])