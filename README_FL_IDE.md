# Termux Packages - FL_IDE Edition

🎯 **Versão customizada dos pacotes Termux compilados especificamente para o aplicativo FL_IDE**

---

## 📝 Sobre Este Fork

Este é um fork do repositório oficial [termux/termux-packages](https://github.com/termux/termux-packages) modificado para compilar binários do Bootstrap do Termux para o aplicativo **FL_IDE** (com.yato.fl_ide).

### Diferenças do Original

- ✅ **Package Name**: Alterado de `com.termux` para `com.yato.fl_ide`
- ✅ **Installation Path**: `/data/data/com.yato.fl_ide/files/usr/`
- ✅ **App Data Dir**: `/data/data/com.yato.fl_ide/`
- ✅ **GitHub Actions**: Configurado para funcionar em qualquer fork
- ✅ **Releases**: Customizadas para FL_IDE

---

## 🚀 Quick Start

### Opção 1: Usar GitHub Actions (Recomendado)

1. **Fork este repositório** para sua conta GitHub
2. Vá em **Actions** > **Generate bootstrap archives (android-7)**
3. Clique em **Run workflow**
4. Aguarde a compilação (30-60 minutos)
5. Baixe os binários da seção **Releases**

### Opção 2: Compilar Localmente

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/termux-packages-fl-ide.git
cd termux-packages-fl-ide

# Instalar dependências (Ubuntu/Debian)
sudo ./scripts/setup-ubuntu.sh

# Gerar bootstraps para todas as arquiteturas
./scripts/generate-bootstraps.sh

# Ou para uma arquitetura específica
./scripts/generate-bootstraps.sh --architectures aarch64
```

---

## 📦 Arquiteturas Suportadas

| Arquitetura | Descrição | Prioridade | Uso |
|-------------|-----------|------------|-----|
| **aarch64** | ARM 64-bit | ⭐⭐⭐ Alta | Dispositivos Android modernos (2017+) |
| **arm** | ARM 32-bit | ⭐⭐ Média | Dispositivos Android antigos |
| **x86_64** | Intel/AMD 64-bit | ⭐ Baixa | Emuladores (BlueStacks, Genymotion) |
| **i686** | Intel/AMD 32-bit | ⭐ Baixa | Emuladores antigos |

**Recomendação**: Compile pelo menos `aarch64` e `arm` para máxima compatibilidade.

---

## 📁 Estrutura do Projeto

```
termux-packages-master/
│
├── 📄 README_FL_IDE.md              ← Este arquivo
├── 📄 CHANGELOG_FL_IDE.md           ← Changelog das modificações
├── 📄 verify-fl-ide-termux.sh       ← Script de verificação
│
├── 📁 .github/
│   └── workflows/
│       ├── bootstrap_archives.yml   ← Workflow principal (MODIFICADO)
│       ├── packages.yml             ← Build de pacotes individuais
│       └── docker_image.yml         ← Docker para build
│
├── 📁 scripts/
│   ├── properties.sh                ← MODIFICADO (config do pacote)
│   ├── generate-bootstraps.sh       ← Geração de bootstraps
│   ├── build-bootstraps.sh          ← Build de bootstraps
│   └── build-package.sh             ← Build de pacotes individuais
│
├── 📁 packages/                     ← ~2000 pacotes disponíveis
├── 📁 x11-packages/                 ← ~70 pacotes X11
├── 📁 root-packages/                ← Pacotes que requerem root
└── 📁 disabled-packages/            ← Pacotes desabilitados
```

---

## 🔧 Configuração Principal

### scripts/properties.sh

```bash
# Package name do aplicativo FL_IDE
TERMUX_APP__PACKAGE_NAME="com.yato.fl_ide"

# Diretório de dados do app
TERMUX_APP__DATA_DIR="/data/data/com.yato.fl_ide"

# Prefix de instalação dos binários
TERMUX__PREFIX="/data/data/com.yato.fl_ide/files/usr"

# Home do usuário
TERMUX__HOME="/data/data/com.yato.fl_ide/files/home"
```

---

## 📦 Outputs Gerados

Após executar o workflow ou build local, você receberá:

### Bootstrap Archives

```
bootstrap-aarch64.zip    (~50-80 MB)
bootstrap-arm.zip        (~45-75 MB)
bootstrap-x86_64.zip     (~55-85 MB)
bootstrap-i686.zip       (~50-80 MB)
```

Cada arquivo contém:
- ✅ Sistema de arquivos completo do Termux
- ✅ APT package manager configurado
- ✅ Ferramentas essenciais (bash, coreutils, etc)
- ✅ Biblioteca padrão C (libc)
- ✅ Binários compilados para `/data/data/com.yato.fl_ide/files/usr/`

### Estrutura Interna do Bootstrap

```
usr/
├── bin/           # Executáveis
├── lib/           # Bibliotecas compartilhadas
├── include/       # Headers C/C++
├── share/         # Dados compartilhados
├── var/           # Dados variáveis (apt, dpkg)
├── etc/           # Arquivos de configuração
└── SYMLINKS.txt   # Lista de symlinks a serem criados
```

---

## 🔨 Uso dos Bootstraps

### Integração no FL_IDE

```java
public class BootstrapManager {
    private static final String APP_PACKAGE = "com.yato.fl_ide";
    private static final String BASE_DIR = "/data/data/" + APP_PACKAGE + "/files";
    private static final String PREFIX = BASE_DIR + "/usr";
    
    public void installBootstrap(File bootstrapZip, String arch) {
        // 1. Extrair bootstrap
        extractZip(bootstrapZip, new File(PREFIX));
        
        // 2. Processar symlinks
        File symlinksFile = new File(PREFIX, "SYMLINKS.txt");
        processSymlinks(symlinksFile);
        
        // 3. Definir permissões executáveis
        setExecutablePermissions(new File(PREFIX, "bin"));
        setExecutablePermissions(new File(PREFIX, "lib"));
        
        // 4. Configurar ambiente
        setupEnvironment();
    }
    
    private void processSymlinks(File symlinksFile) throws IOException {
        // Formato: target←link
        BufferedReader reader = new BufferedReader(new FileReader(symlinksFile));
        String line;
        while ((line = reader.readLine()) != null) {
            String[] parts = line.split("←");
            if (parts.length == 2) {
                String target = parts[0];
                String link = parts[1];
                createSymlink(link, target);
            }
        }
        reader.close();
        
        // Remover SYMLINKS.txt após processar
        symlinksFile.delete();
    }
    
    private void setupEnvironment() {
        Map<String, String> env = new HashMap<>();
        env.put("HOME", BASE_DIR + "/home");
        env.put("PREFIX", PREFIX);
        env.put("TMPDIR", PREFIX + "/tmp");
        env.put("PATH", PREFIX + "/bin:" + PREFIX + "/bin/applets");
        env.put("LD_LIBRARY_PATH", PREFIX + "/lib");
        
        // Executar setup inicial
        executeCommand(PREFIX + "/bin/bash", "-c", "apt update");
    }
}
```

### Primeiro Uso

```bash
# Após instalar o bootstrap, execute:
/data/data/com.yato.fl_ide/files/usr/bin/bash

# Atualizar lista de pacotes
apt update

# Instalar pacotes adicionais
apt install git python nodejs vim
```

---

## 🎨 Customização

### Adicionar Pacotes ao Bootstrap

```bash
# Editar scripts/generate-bootstraps.sh
# Adicionar na seção de pacotes:
pull_package seu-pacote
```

### Compilar Pacote Individual

```bash
# Build de um pacote específico
./build-package.sh nome-do-pacote

# Exemplo
./build-package.sh git
```

### Usar Repositório Customizado

```bash
# Editar scripts/generate-bootstraps.sh
# Alterar REPO_BASE_URL:
REPO_BASE_URL="https://seu-repo.com/apt/termux-main"
```

---

## 🧪 Verificação

Execute o script de verificação para garantir que tudo está configurado:

```bash
./verify-fl-ide-termux.sh
```

**Output esperado:**
```
✅ SUCESSO! Todas as verificações passaram!
O projeto está pronto para compilar bootstraps para FL_IDE (com.yato.fl_ide)
```

---

## 🐛 Troubleshooting

### Erro: "Permission denied"

```bash
chmod +x scripts/*.sh
chmod +x build-package.sh
chmod +x verify-fl-ide-termux.sh
```

### Erro: "No space left on device"

O build requer ~20-30 GB de espaço livre. Libere espaço ou use um volume maior.

### Erro no GitHub Actions

Certifique-se de que:
1. O repositório é público ou você tem GitHub Actions habilitado
2. Tem permissões para criar releases
3. Não há limites de tempo de build excedidos

### Build muito lento

Use Docker para build mais rápido:

```bash
./scripts/run-docker.sh ./build-package.sh nome-do-pacote
```

---

## 📚 Pacotes Disponíveis

### Essenciais (já incluídos no bootstrap)

- bash, dash, zsh
- coreutils, findutils, diffutils
- apt, dpkg
- curl, wget
- tar, gzip, xz-utils, zstd
- grep, sed, awk

### Desenvolvimento

- git, subversion, mercurial
- gcc, clang, make, cmake
- python, nodejs, ruby, perl, php
- go, rust, swift, kotlin

### Editores

- vim, neovim, emacs, nano
- micro, helix, kakoune

### Utilitários

- htop, btop, gotop
- tmux, screen
- openssh, rsync
- ffmpeg, imagemagick

**Total**: Mais de 2000 pacotes disponíveis!

Veja lista completa em: https://packages.termux.dev

---

## 🤝 Contribuindo

1. Fork este repositório
2. Crie uma branch: `git checkout -b minha-feature`
3. Commit suas mudanças: `git commit -am 'Add feature'`
4. Push para a branch: `git push origin minha-feature`
5. Abra um Pull Request

---

## 📜 Licença

Este projeto mantém a mesma licença do [termux-packages](https://github.com/termux/termux-packages) original.

---

## 🔗 Links Úteis

- **Termux Wiki**: https://wiki.termux.com
- **Termux Packages Original**: https://github.com/termux/termux-packages
- **Package Search**: https://packages.termux.dev
- **Termux Discord**: https://discord.gg/termux
- **Documentação Build System**: https://github.com/termux/termux-packages/wiki/Build-system

---

## ⚠️ Avisos Importantes

1. **Package Name**: Seu app FL_IDE DEVE usar `com.yato.fl_ide` como package name
2. **Permissões**: O app precisa de permissões para escrever em `/data/data/com.yato.fl_ide/`
3. **Android Version**: Bootstraps são compatíveis com Android 7.0+ por padrão
4. **Espaço**: Requer ~500 MB - 2 GB de espaço no dispositivo após instalação

---

## 📊 Estatísticas

- **Pacotes Disponíveis**: 2000+
- **Arquivos Modificados**: 59
- **Substituições Realizadas**: 140
- **Tempo de Build**: ~30-60 min por arquitetura
- **Tamanho do Projeto**: ~13 MB (compactado)
- **Tamanho dos Bootstraps**: ~50-80 MB cada

---

## 🎉 Status

✅ **PRONTO PARA PRODUÇÃO**

- Todas as referências a `com.termux` foram substituídas
- Workflow do GitHub Actions configurado
- Documentação completa
- Scripts de verificação funcionando

---

**Versão**: FL_IDE Edition v1.0
**Data**: Março 2026
**Baseado em**: termux-packages (oficial)
**Modificado para**: com.yato.fl_ide

---

## 📞 Suporte

Para problemas:
1. Verifique a seção **Troubleshooting** acima
2. Consulte a [Termux Wiki](https://wiki.termux.com)
3. Abra uma issue neste repositório
4. Para problemas do Termux original, veja [termux/termux-packages](https://github.com/termux/termux-packages/issues)
