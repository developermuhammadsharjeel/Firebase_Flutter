# Contributing to Chatify

Thank you for considering contributing to Chatify! We welcome contributions from everyone.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear title and description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Environment details (Flutter version, OS, etc.)

### Suggesting Features

Feature suggestions are welcome! Please open an issue with:
- Clear description of the feature
- Use case and benefits
- Any implementation ideas you have

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/developermuhammadsharjeel/Firebase_Flutter.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments where necessary
   - Update documentation if needed

4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**
   ```bash
   git commit -m "Add: brief description of your changes"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Provide a clear description of changes
   - Reference any related issues
   - Include screenshots for UI changes

## Code Style Guidelines

### Dart/Flutter

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use `const` constructors where possible

### File Organization

```
lib/
├── models/         # Data models
├── repositories/   # Data layer
├── viewmodels/     # Business logic
├── views/          # UI screens
├── services/       # External services
└── utils/          # Utility functions
```

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private members**: prefix with `_`

## Testing

- Write unit tests for new features
- Ensure all tests pass before submitting PR
- Test on both Android and iOS if possible

## Documentation

- Update README.md if adding features
- Add inline comments for complex logic
- Update FIREBASE_SETUP.md if changing Firebase configuration

## Code Review Process

1. Pull requests will be reviewed by maintainers
2. Address any feedback or requested changes
3. Once approved, your PR will be merged

## Community Guidelines

- Be respectful and constructive
- Help others in issues and discussions
- Follow the code of conduct

## Getting Help

- Open an issue for questions
- Check existing issues and documentation first
- Be patient - we're all volunteers

## Recognition

Contributors will be acknowledged in the README and release notes.

Thank you for contributing to Chatify! 🎉
