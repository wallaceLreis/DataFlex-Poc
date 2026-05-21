// =============================================================================
// PAINEL DE CONTROLE DE ESTOQUE
// Tela de Visualiza‡Æo, Consulta e A‡äes do Estoque (Estoque.vw)
// =============================================================================

// 1. InclusÆo de Bibliotecas e Pacotes
Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg
Use cCJCommandBarSystem.pkg
Use cCJStandardCommandBarSystem.pkg

// 2. Registro de Objetos Externos (Evita erros de s¡mbolo nÆo definido / Forward Reference)
Register_Object oCadastroEstoque
Register_Object oMovimentacaoDeEstoque

// 3. Comando de Ativa‡Æo da View
Activate_View Activate_oEstoque for oEstoque

// 4. Estrutura Principal da View (dbView)
Object oEstoque is a dbView
    Set Label to "Estoque"
    Set Size to 212 421
    Set Location to 0 0

    // 4.1. Ciclo de Vida e M‚todos da View
    
    // Evento disparado automaticamente toda vez que a View ganha foco ou ‚ aberta
    Procedure OnOnEntry
        Forward Send OnOnEntry
        Send DoFillGrid of oGrid2
    End_Procedure

    // 4.2. Sistema de Menus e A‡äes (Codejock)
    Object oCJCommandBarSystem1 is a cCJCommandBarSystem
        Object oCJMenuBar1 is a cCJMenuBar
            
            // BotÆo de A‡Æo: Cadastrar Estoque
            Object oCadastroMenuItem is a cCJMenuItem
                Set psCaption to "Cadastrar Estoque"
                Set psTooltip to "Abre a tela de cadastro de estoque"
                
                Procedure OnExecute
                    Send Popup to oCadastroEstoque
                    Send DoFillGrid of oGrid2
                End_Procedure
            End_Object

            // BotÆo de A‡Æo: Ver Movimenta‡äes (Filtrado)
            Object oMovimentacaoMenuItem is a cCJMenuItem
                Set psCaption to "Movimenta‡äes"
                Set psTooltip to "Ver movimenta‡äes do local selecionado"

                Procedure OnExecute Variant vCommandBarControl
                    Integer iCurrentItem iRow iColLocal iTotalItems
                    String sLocal
                    Handle hoClient

                    // Captura o total de itens e o item focado
                    Get Item_Count of oGrid2 to iTotalItems
                    Get Current_Item of oGrid2 to iCurrentItem
                    
                    // PROTE€ÇO: S¢ processa se a Grid tiver dados e houver uma linha selecionada
                    If (iTotalItems > 0 and iCurrentItem >= 0) Begin
                        // Descobre a linha dividindo pelo n£mero de colunas do estoque (5)
                        Move (iCurrentItem / 5) to iRow
                        
                        // O Local est  na primeira coluna (¡ndice 0 da linha calculada)
                        Move (iRow * 5) to iColLocal
                        
                        // Garante que a coluna calculada existe dentro dos limites atuais da Grid
                        If (iColLocal < iTotalItems) Begin
                            // Recupera o valor do local gravado na c‚lula da Grid
                            Get Value of oGrid2 item iColLocal to sLocal
                            
                            // Abre a tela de movimenta‡äes via escopo MDI Client
                            Get Client_Id to hoClient
                            Send Activate_oMovimentacaoDeEstoque of hoClient
                            
                            // Envia o c¢digo do local para filtrar a abertura da tela se ela estiver ativa
                            If (oMovimentacaoDeEstoque(hoClient)) Begin
                                Send FiltrarMovimentacaoPorLocal of (oMovimentacaoDeEstoque(hoClient)) sLocal
                            End
                        End
                    End
                    Else Begin
                        Send Info_Box "NÆo h  registros na tabela ou nenhuma linha foi selecionada." "Aviso"
                    End
                End_Procedure
            End_Object

            // BotÆo de A‡Æo: Excluir Estoque Selecionado
            Object oExcluirEstoqueMenuItem is a cCJMenuItem
                Set psCaption to "Excluir Estoque"
                Set psTooltip to "Excluir o registro de estoque selecionado"

                Procedure OnExecute Variant vCommandBarControl
                    Integer iCurrentItem iRow iColLocal iResposta iTotalItems
                    String sLocal

                    Get Item_Count of oGrid2 to iTotalItems
                    Get Current_Item of oGrid2 to iCurrentItem

                    If (iTotalItems > 0 and iCurrentItem >= 0) Begin
                        Move (iCurrentItem / 5) to iRow
                        Move (iRow * 5) to iColLocal

                        If (iColLocal < iTotalItems) Begin
                            // Captura o c¢digo do local correspondente … linha focado
                            Get Value of oGrid2 item iColLocal to sLocal

                            Get YesNo_Box ("Deseja realmente excluir o registro de estoque do local: " + Trim(sLocal) + "?") "Confirma‡Æo" MB_DEFBUTTON2 to iResposta
                            If (iResposta = MBR_Yes) Begin
                                Open Estoque
                                Clear estoque
                                Move sLocal to estoque.local
                                Find eq estoque by Index.1
                                
                                // Se encontrou o registro chave, realiza o bloqueio e a exclusÆo
                                If (Found) Begin
                                    Reread estoque
                                        Delete estoque
                                    Unlock
                                    Send Info_Box "Registro de estoque exclu¡do com sucesso!" "Sucesso"
                                    Send DoFillGrid of oGrid2
                                End
                            End
                        End
                    End
                    Else Begin
                        Send Info_Box "Selecione um registro de estoque na tabela para excluir." "Aviso"
                    End
                End_Procedure
            End_Object
        End_Object
    End_Object
    
    // 4.3. Grid de Exibi‡Æo de Dados (Estoque integrado com Produtos)
    Object oGrid2 is a Grid
        Set Location to 19 5
        Set Size to 189 413
        Set Line_Width to 5 0 
        
        // Configura‡Æo e Dimensionamento das Colunas
        Set Form_Width 0 to 47
        Set Header_Label 0 to "Local"
        Set Form_Width 1 to 47 
        Set Header_Label 1 to "Cod. Prod"
        Set Form_Width 2 to 200
        Set Header_Label 2 to "Desc. Produto" 
        Set Form_Width 3 to 40
        Set Header_Label 3 to "Quant."
        Set Form_Width 4 to 80
        Set Header_Label 4 to "Data de Altera‡Æo"
        
        // Rotina de carga manual realizando o Relacionamento via C¢digo (Estoque -> Produtos)
        Procedure DoFillGrid
            Integer iItem
            Send Delete_Data
            
            Open Estoque
            Open Produtos
            
            Clear estoque
            Find ge estoque by Index.1
            
            While (Found)
                // Busca o relacionamento do produto para exibir a descri‡Æo em tempo de execu‡Æo
                Clear produtos
                Move estoque.codprod to produtos.codprod
                Find eq produtos by Index.1
                
                // Alimenta a linha da Grid
                Send Add_Item msg_None estoque.local
                Send Add_Item msg_None estoque.codprod
                Send Add_Item msg_None produtos.descricao
                Send Add_Item msg_None estoque.quantidade
                Send Add_Item msg_None estoque.data_alteracao
                
                // Recupera o total de itens para aplicar o estado Shadow (Somente leitura) nas c‚lulas
                Get Item_Count to iItem
                
                Set Item_Shadow_State (iItem - 5) to True
                Set Item_Shadow_State (iItem - 4) to True
                Set Item_Shadow_State (iItem - 3) to True
                Set Item_Shadow_State (iItem - 2) to True
                Set Item_Shadow_State (iItem - 1) to True
                
                Find gt estoque by Index.1
            Loop
        End_Procedure
        
        // Evento p¢s-constru‡Æo do componente que for‡a a primeira carga dos dados
        Procedure End_Construct_object
            Forward Send End_Construct_Object
            Send DoFillGrid            
        End_Procedure
               
    End_Object

End_Object