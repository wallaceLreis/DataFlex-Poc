// =============================================================================
// EDIÄ«O DE PRODUTOS
// Tela de Alteraá∆o/Ediá∆o de Produto Existente (EditaProduto.vw)
// =============================================================================

// 1. Inclus∆o de Bibliotecas e Pacotes
Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg
Use cprodutosDataDictionary.dd

// 2. Registro de Objetos Externos (Evita erros de Forward Reference)
Register_Object oProdutos

// 3. Comando de Ativaá∆o da View
Activate_View Activate_oEditaProduto for oEditaProduto

// 4. Estrutura Principal da View (dbView)
Object oEditaProduto is a dbView
    Set Label to "Ediá∆o de Produto"
    Set Size to 115 298
    Set Location to 0 0

    // 4.1. Estrutura do Data Dictionary (Camada de Neg¢cio/Banco de Dados)
    Object oprodutos_DD is a cprodutosDataDictionary
    End_Object 

    // Vinculaá∆o da View ao Data Dictionary Principal
    Set Main_DD to oprodutos_DD
    Set Server  to oprodutos_DD

    // 4.2. Elementos de Interface Visual (Camada de Apresentaá∆o / DEOs)

    // Campo C¢digo do Produto (Chave Prim†ria - Desabilitado para ediá∆o)
    Object oprodutos_codprod is a dbForm
        Entry_Item produtos.codprod
        Set Label to "Cod. Produto:"
        Set Location to 19 75
        Set Size to 15 50
        Set Label_Col_Offset to 65
        Set Label_Justification_mode to jMode_Left
        Set Enabled_State to False
    End_Object

    // Campo Descriá∆o do Produto
    Object oprodutos_descricao is a dbForm
        Entry_Item produtos.descricao
        Set Label to "Descriá∆o:"
        Set Location to 47 75
        Set Size to 15 195
        Set Label_Col_Offset to 65
        Set Label_Justification_mode to jMode_Left
        Set Capslock_State to True
    End_Object

    // Bot∆o de Aá∆o: Salvar Alteraá‰es
    Object oButton1 is a Button
        Set Label to 'Salvar'
        Set Location to 77 210
        Set Size to 20 60
    
        // Rotina de persistància e validaá∆o das alteraá‰es
        Procedure OnClick
            Handle hoDD
            Boolean bHasChanged
            
            // ObtÇm a referància do Data Dictionary corrente
            Get Server to hoDD 
                                      
            // Dispara a gravaá∆o no banco via DataDictionary
            Send Request_Save of hoDD
                                     
            // Verifica se ainda existem pendàncias de alteraá∆o (se salvou com sucesso, retorna False)
            Get Should_Save of hoDD to bHasChanged
            
            // Se gravou com sucesso e n∆o h† pendàncias, atualiza a grid anterior e fecha
            If (not(bHasChanged)) Begin
                Send AtualizaGrid of oProdutos
                Send Close_Panel
            End
        End_Procedure
    End_Object

    // 4.3. Interface de MÇtodos P£blicos da View
    
    // MÇtodo que recebe o c¢digo vindo da Grid e realiza a busca autom†tica do registro
    Procedure RetornaProdutoEditar String sCodProd
        Handle hoDD
        Get Server to hoDD
        
        Send Clear of hoDD
        Move sCodProd to produtos.codprod
        Send Find of hoDD EQ 1
    End_Procedure

End_Object