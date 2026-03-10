#!/bin/bash
##
## Script de verificação das modificações para FL_IDE
## Termux Packages Edition
##

echo "=========================================="
echo "Verificação FL_IDE - Termux Packages"
echo "=========================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contador de verificações
PASSED=0
FAILED=0

echo "1. Verificando pacote antigo (com.termux)..."
OLD_COUNT=$(find . -type f ! -path "./.git/*" ! -name "*.md" ! -name "verify-fl-ide-termux.sh" -exec grep -l "com\.termux" {} \; 2>/dev/null | wc -l)
if [ "$OLD_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Nenhuma referência ao pacote antigo encontrada"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - Encontradas $OLD_COUNT referências ao pacote antigo"
    echo "  Execute: find . -type f -exec grep -l 'com.termux' {} \\;"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "2. Verificando novo pacote (com.yato.fl_ide)..."
NEW_COUNT=$(find . -type f ! -path "./.git/*" -exec grep -l "com\.yato\.fl_ide" {} \; 2>/dev/null | wc -l)
if [ "$NEW_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Encontradas referências ao novo pacote em $NEW_COUNT arquivos"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALHOU${NC} - Nenhuma referência ao novo pacote encontrada"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "3. Verificando scripts/properties.sh..."
if [ -f "scripts/properties.sh" ]; then
    if grep -q 'TERMUX_APP__PACKAGE_NAME="com.yato.fl_ide"' scripts/properties.sh 2>/dev/null; then
        echo -e "${GREEN}✓ PASSOU${NC} - TERMUX_APP__PACKAGE_NAME está correto"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FALHOU${NC} - TERMUX_APP__PACKAGE_NAME não está correto"
        FAILED=$((FAILED + 1))
    fi

    if grep -q '/data/data/com.yato.fl_ide' scripts/properties.sh 2>/dev/null; then
        echo -e "${GREEN}✓ PASSOU${NC} - Paths estão corretos"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FALHOU${NC} - Paths não estão corretos"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${RED}✗ FALHOU${NC} - scripts/properties.sh não encontrado"
    FAILED=$((FAILED + 2))
fi
echo ""

echo "4. Verificando scripts essenciais..."
ESSENTIAL_SCRIPTS=(
    "scripts/properties.sh"
    "scripts/generate-bootstraps.sh"
    "scripts/build-bootstraps.sh"
    "scripts/test-runner.sh"
    "build-package.sh"
)

for script in "${ESSENTIAL_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo -e "${GREEN}✓${NC} $script existe"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $script não encontrado"
        FAILED=$((FAILED + 1))
    fi
done
echo ""

echo "5. Verificando workflow de GitHub Actions..."
if [ -f ".github/workflows/bootstrap_archives.yml" ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Workflow de bootstrap encontrado"
    PASSED=$((PASSED + 1))
    
    # Verificar se a restrição de repositório foi removida
    if grep -q "# Modified for FL_IDE" .github/workflows/bootstrap_archives.yml 2>/dev/null; then
        echo -e "${GREEN}✓ PASSOU${NC} - Workflow modificado para FL_IDE"
        PASSED=$((PASSED + 1))
    else
        echo -e "${YELLOW}⚠ ATENÇÃO${NC} - Workflow pode precisar de ajustes"
    fi
else
    echo -e "${RED}✗ FALHOU${NC} - Workflow de bootstrap não encontrado"
    FAILED=$((FAILED + 1))
fi
echo ""

echo "6. Verificando estrutura de diretórios..."
REQUIRED_DIRS=(
    "scripts"
    "packages"
    "x11-packages"
    "root-packages"
    ".github/workflows"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} Diretório $dir existe"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} Diretório $dir não encontrado"
        FAILED=$((FAILED + 1))
    fi
done
echo ""

echo "7. Verificando documentação FL_IDE..."
FL_IDE_DOCS=(
    "README_FL_IDE.md"
    "CHANGELOG_FL_IDE.md"
)

for doc in "${FL_IDE_DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓${NC} $doc existe"
        PASSED=$((PASSED + 1))
    else
        echo -e "${YELLOW}⚠${NC} $doc não encontrado (opcional)"
    fi
done
echo ""

echo "8. Contagem de substituições..."
TOTAL_FILES=$(find . -type f ! -path "./.git/*" -exec grep -l "com\.yato\.fl_ide" {} \; 2>/dev/null | wc -l)
TOTAL_OCCURRENCES=$(grep -r "com\.yato\.fl_ide" . --include="*.sh" --include="*.yml" --include="*.yaml" --include="*.json" --include="*.patch" --include="*.c" 2>/dev/null | wc -l)

echo -e "${BLUE}ℹ${NC} Arquivos com com.yato.fl_ide: $TOTAL_FILES"
echo -e "${BLUE}ℹ${NC} Total de ocorrências: $TOTAL_OCCURRENCES"

if [ "$TOTAL_FILES" -ge 50 ] && [ "$TOTAL_OCCURRENCES" -ge 100 ]; then
    echo -e "${GREEN}✓ PASSOU${NC} - Substituições parecem completas"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠ ATENÇÃO${NC} - Número de substituições abaixo do esperado"
fi
echo ""

echo "=========================================="
echo "Resumo da Verificação"
echo "=========================================="
echo -e "Testes passados: ${GREEN}$PASSED${NC}"
echo -e "Testes falhados: ${RED}$FAILED${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ SUCESSO!${NC} Todas as verificações passaram!"
    echo ""
    echo "O projeto está pronto para compilar bootstraps do Termux para FL_IDE (com.yato.fl_ide)"
    echo ""
    echo "Próximos passos:"
    echo "1. Subir para GitHub: git init && git add . && git commit -m 'Initial commit'"
    echo "2. Executar workflow: Actions > Generate bootstrap archives > Run workflow"
    echo "3. Baixar binários gerados da seção Releases"
    echo "4. Integrar no app FL_IDE"
    echo ""
    echo -e "${BLUE}Dica:${NC} Use './scripts/generate-bootstraps.sh' para build local"
    exit 0
else
    echo -e "${RED}✗ ATENÇÃO!${NC} Algumas verificações falharam."
    echo "Por favor, revise os erros acima antes de continuar."
    echo ""
    echo "Para mais informações, consulte:"
    echo "- README_FL_IDE.md"
    echo "- CHANGELOG_FL_IDE.md"
    exit 1
fi
