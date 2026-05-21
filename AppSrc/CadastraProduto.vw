// =============================================================================
// CADASTRO DE PRODUTOS
// Tela de Inclus∆o/Cadastro de Novo Produto (CadastraProduto.vw)
// =============================================================================

// 1. Inclus∆o de Bibliotecas e Pacotes
Use Windows.pkg
Use DFClient.pkg
Use DFEntry.pkg
Use cprodutosDataDictionary.dd

// 2. Registro de Objetos Externos
Register_Object oProdutos

// 3. Comando de Ativaá∆o da View
Activate_View Activate_oCadastraProduto for oCadastraProduto

// 4. Estrutura Principal da View (dbView)
Object oCadastraProduto is a dbView
    Set Label to "Cadastrar Produto"
    Set Location to 0 0
    Set Size to 82 320
    Set Border_Style to Border_Thick

    // 4.1. Estrutura do Data Dictionary (Camada de Neg¢cio/Banco de Dados)
    Object oprodutos_DD is a cprodutosDataDictionary
    End_Object 

    // Vinculaá∆o da View ao Data Dictionary Principal
    Set Main_DD to oprodutos_DD
    Set Server  to oprodutos_DD

    // 4.2. Elementos de Interface Visual (Camada de Apresentaá∆o / DEOs)
    
    // Campo: Descriá∆o do Produto
    Object oprodutosdescricao is a dbForm
        Entry_Item produtos.descricao
        Set Label to "Descriá∆o"
        Set Location to 20 69
        Set Size to 13 230
        Set peAnchors to anTopLeftRight
        Set Capslock_State to True
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 60
        Set Label_row_Offset to 0
    End_Object 

    // Bot∆o de Aá∆o: Salvar Registro
    Object oButton1 is a Button
        Set Label to 'Salvar'
        Set Location to 41 98
        Set Size to 28 134
    
        // Rotina de persistància e validaá∆o dos dados
        Procedure OnClick
            Handle hoDD
            Boolean bHasChanged
            
            // ObtÇm a referància do Data Dictionary corrente
            Get Server to hoDD 
                      
            // Solicita a gravaá∆o do registro ao Data Dictionary
            Send Request_Save of hoDD
                     
            // Verifica se ainda existem pendàncias de alteraá∆o (se falhou, retorna True)
            Get Should_Save of hoDD to bHasChanged
            
            // Se salvou com sucesso, atualiza a grid principal e fecha o painel
            If (not(bHasChanged)) Begin
                Send AtualizaGrid of oProdutos
                Send Close_Panel
            End
        End_Procedure
    End_Object

End_Object