// =============================================================================
// CONSULTA DE PRODUTOS
// Tela Principal de Visualiza‡Æo e Gerenciamento de Produtos (Produtos.vw)
// =============================================================================

// 1. InclusÆo de Bibliotecas e Pacotes
Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg
Use cCJCommandBarSystem.pkg
Use cCJStandardCommandBarSystem.pkg

// 2. Registro de Objetos Externos (Evita erros de s¡mbolo nÆo definido / Forward Reference)
Register_Object oEditaProduto
Register_Object oCadastraProduto
Register_Object oExcluiProduto

// 3. Comando de Ativa‡Æo da View
Activate_View Activate_oProdutos for oProdutos

// 4. Estrutura Principal da View (dbView)
Object oProdutos is a dbView
    Set Label to "Produtos"
    Set Size to 212 421
    Set Location to 0 0

    // 4.1. Interface de M‚todos P£blicos da View
    
    // M‚todo chamado externamente para for‡ar o recarregamento dos dados na Grid
    Procedure AtualizaGrid
        Send DoFillGrid of oGrid1
    End_Procedure

    // 4.2. Sistema de Menus e A‡äes (Codejock)
    Object oCJCommandBarSystem1 is a cCJCommandBarSystem
        Object oCJMenuBar1 is a cCJMenuBar

            // BotÆo de A‡Æo: Cadastrar Novo Produto
            Object oCadastraProdutoMenuItem is a cCJMenuItem
                Set psCaption to "Cadastrar"
                Set psTooltip to "CadastraProduto"
            
                Procedure OnExecute Variant vCommandBarControl
                    Handle hoClient
                    Get Client_Id to hoClient
                    Send Activate_oCadastraProduto of hoClient
                End_Procedure
            End_Object

            // BotÆo de A‡Æo: Editar Produto Selecionado
            Object oEditarMenuItem is a cCJMenuItem
                Set psCaption to "Editar"
                Set psTooltip to "Editar"

                Procedure OnExecute Variant vCommandBarControl
                    Integer iCurrentItem iRow iColCod
                    String sCodProd
                    Handle hoClient

                    // 1. Pega o item atualmente focado na Grid (0, 1, 2, 3, 4...)
                    Get Current_Item of oGrid1 to iCurrentItem
                    
                    If (iCurrentItem >= 0) Begin
                        // Descobre a linha atual dividindo o item pelo n£mero de colunas (4)
                        Move (iCurrentItem / 4) to iRow
                        
                        // Calcula o ¡ndice do primeiro item daquela linha (onde fica o C¢digo)
                        Move (iRow * 4) to iColCod
                        
                        // Pega o c¢digo do produto na primeira coluna da linha ativa
                        Get Value of oGrid1 item iColCod to sCodProd
                        
                        // 2. Abre a tela de EDI€ÇO
                        Get Client_Id to hoClient
                        Send Activate_oEditaProduto of hoClient
                        
                        // 3. Comanda a tela de edi‡Æo a buscar o produto se ela estiver ativa
                        If (oEditaProduto(hoClient)) Begin
                            Send RetornaProdutoEditar of (oEditaProduto(hoClient)) sCodProd
                        End
                    End
                End_Procedure
            End_Object

            // BotÆo de A‡Æo: Excluir Produto Selecionado
            Object oExcluirMenuItem is a cCJMenuItem
                Set psCaption to "Excluir"
                Set psTooltip to "Excluir"

                Procedure OnExecute Variant vCommandBarControl
                    Integer iCurrentItem iRow iColCod
                    String sCodProd

                    // 1. Pega o item ativo na Grid para saber qual linha est  selecionada
                    Get Current_Item of oGrid1 to iCurrentItem
                    
                    If (iCurrentItem >= 0) Begin
                        Move (iCurrentItem / 4) to iRow
                        Move (iRow * 4) to iColCod
                        
                        // Captura o valor da coluna chave (C¢digo)
                        Get Value of oGrid1 item iColCod to sCodProd
                        
                        // 2. Repassa o c¢digo para a propriedade interna do modal
                        Set psCodProdExcluir of oExcluiProduto to sCodProd
                        
                        // 3. Abre o modal em tela
                        Send Popup of oExcluiProduto
                    End
                End_Procedure
            End_Object
        End_Object
    End_Object
       
    // 4.3. Grid de Exibi‡Æo dos Dados
    Object oGrid1 is a Grid
        Set Location to 19 5   
        Set Size to 189 413
        Set Line_Width to 4 0 
    
        // Configura‡Æo e Dimensionamento das Colunas
        Set Form_Width    0 to 47
        Set Header_Label  0 to "C¢digo"   
        Set Form_Width    1 to 200
        Set Header_Label  1 to "Descri‡Æo"    
        Set Form_Width    2 to 80
        Set Header_Label  2 to "InclusÆo"        
        Set Form_Width    3 to 80
        Set Header_Label  3 to "Altera‡Æo"
    
        // Rotina de carga manual de dados via loop no Banco de Dados
        Procedure DoFillGrid 
            Integer iItem
            Send Delete_Data
            
            Open Produtos
            Clear produtos
            Find ge produtos by Index.1 
                            
            While (Found)
                // Alimenta a linha atual da Grid
                Send Add_Item msg_None produtos.codprod
                Send Add_Item msg_None produtos.descricao
                Send Add_Item msg_None produtos.data_inclusao
                Send Add_Item msg_None produtos.data_alteracao
                
                // Recupera o total de itens para aplicar estilo de somente leitura (Shadow) nas c‚lulas
                Get Item_Count to iItem
                
                Set Item_Shadow_State (iItem - 4) to True
                Set Item_Shadow_State (iItem - 3) to True
                Set Item_Shadow_State (iItem - 2) to True
                Set Item_Shadow_State (iItem - 1) to True
    
                Find gt produtos by Index.1
            Loop
        End_Procedure
            
        // Evento de ciclo de vida disparado ap¢s a cria‡Æo do objeto
        Procedure End_Construct_Object 
            Forward Send End_Construct_Object
            Send DoFillGrid  
        End_Procedure   
    End_Object
    
End_Object