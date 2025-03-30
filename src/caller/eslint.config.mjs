// @ts-check

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService  : { allowDefaultProject: [
          'src/confy.ts',
          'src/*wip.{js,jsx,ts,tsx}',
          'src/build/*.{js,jsx,ts,tsx}',
          // Test Folders  (TODO: How to recurse)
          'src/*.test.{js,jsx,ts,tsx}',
          'src/confy/tools/*.test.{js,jsx,ts,tsx}',
          // Examples  (TODO: How to recurse)
          'examples/minimal/*.{js,jsx,ts,tsx}'
        ]},
        tsconfigRootDir : import.meta.dirname,
      }
    },
    rules: {
      // Recommended Disables
      "@typescript-eslint/no-namespace"                      : "off",
      // Strict Disables
      "@typescript-eslint/no-unnecessary-type-arguments"     : "off",
      "@typescript-eslint/no-confusing-void-expression"      : "off",
      // Stylistic Disables
      "@typescript-eslint/consistent-type-definitions"       : "off",
      "@typescript-eslint/no-inferrable-types"               : "off",
      "@typescript-eslint/non-nullable-type-assertion-style" : "off"
    },
  },

  {
    ignores: ["public/**",  "bin/**",  "ref/**",  "butcher/**", 'src/confy/tools/minisign.js', "eslint.config.mjs", ],
  }
);

