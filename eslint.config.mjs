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
        projectService  : { allowDefaultProject: ['src/*.test.{js,jsx,ts,tsx}', 'src/*wip.{js,jsx,ts,tsx}'] }, //, 'src/tools/*.{js,jsx,ts,tsx}'
        tsconfigRootDir : import.meta.dirname,
      }
    },
    rules: {
      // Stylistic Disables
      "@typescript-eslint/consistent-type-definitions": "off",
      "@typescript-eslint/no-inferrable-types": "off"
    },
  },

  {
    ignores: ["public/**",  "eslint.config.mjs"],
  }
);

