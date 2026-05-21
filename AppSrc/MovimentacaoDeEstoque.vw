// =============================================================================
// HISTàRICO DE MOVIMENTA€åES DE ESTOQUE
// Tela de Consulta e Manuten‡Æo de Log de Movimentos (MovimentacaoDeEstoque.vw)
// =============================================================================

// 1. InclusÆo de Bibliotecas e Pacotes
Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg
Use cCJCommandBarSystem.pkg
Use cCJStandardCommandBarSystem.pkg

// 2. Registro de Objetos Externos (Evita erros de s¡mbolo nÆo definido / Forward Reference)
Register_Object oMovimentaEstoque

// 3. Comando de Ativa‡Æo da View
Activate_View Activate_oMovimentacaoDeEstoque for oMovimentacaoDeEstoque

// 4. Estrutura Principal da View (dbView)
Object oMovimentacaoDeEstoque is a dbView
    Set Label to "Movimenta‡Æo de Estoque"
    Set Size to 212 421
    Set Location to 0 0

    // Propriedade interna para persistir e gerenciar o filtro ativo na tela
    Property String psFiltroLocal ""

    // 4.1. Interface de M‚todos P£blicos da View
    
    // M‚todo p£blico invocado pela tela de estoque para aplicar o filtro e recarregar a Grid
    Procedure FiltrarMovimentacaoPorLocal String sLocal
        Set psFiltroLocal to sLocal
        Send DoFillGrid of oGrid1
    End_Procedure

    // 4.2. Sistema de Menus e A‡äes (Codejock)
    Object oCJCommandBarSystem1 is a cCJCommandBarSystem
        Object oCJMenuBar1 is a cCJMenuBar
            
            // BotÆo de A‡Æo: Lan‡ar Nova Movimenta‡Æo (Entrada/Sa¡da)
            Object oMovimentarMenuItem is a cCJMenuItem
                Set psCaption to "Movimentar"
                Set psTooltip to "Movimentar"
                
                Procedure OnExecute Variant vCommandBarControl
                    Integer iCurrentItem iRow iColLocal iTotalItems
                    String sLocal sCodProd
                    
                    // Verifica quantos itens existem na Grid antes de processar
                    Get Item_Count of oGrid1 to iTotalItems
                    Get Current_Item of oGrid1 to iCurrentItem
                    
                    // PROTE€ÇO: S¢ prossegue se houver itens e se houver uma sele‡Æo v lida (maior ou igual a 0)
                    If (iTotalItems > 0 and iCurrentItem >= 0) Begin
                        Move (iCurrentItem / 5) to iRow
                        Move (iRow * 5) to iColLocal
                        
                        // Garante que o ¡ndice calculado da coluna existe na Grid
                        If (iColLocal + 1 < iTotalItems) Begin
                            // Captura o C¢d. Local da linha selecionada (Segunda coluna)
                            Get Value of oGrid1 item (iColLocal + 1) to sLocal
                            
                            // Abre a tabela estoque para descobrir qual produto pertence a este local
                            Open Estoque
                            Clear estoque
                            Move sLocal to estoque.local
                            Find ge estoque by Index.1
                            
                            If (Found and Trim(estoque.local) = Trim(sLocal)) Begin
                                Move estoque.codprod to sCodProd
                            End
                            
                            // Passa as informa‡äes necess rias para as propriedades do modal
                            Set psLocalMov   of oMovimentaEstoque to sLocal
                            Set psCodProdMov of oMovimentaEstoque to sCodProd
                            
                            // Abre o modal de inser‡Æo de Entrada/Sa¡da
                            Send Popup to oMovimentaEstoque
                            
                            // Atualiza a grid atual ap¢s o fechamento do modal
                            Send DoFillGrid of oGrid1
                        End
                    End
                    Else Begin
                        Send Info_Box "NÆo h  registros na tabela ou nenhuma linha foi selecionada." "Aviso"
                    End
                End_Procedure
            End_Object

            // BotÆo de A‡Æo: Limpar Hist¢rico de Movimenta‡äes // Fun‡Æo desativada por questäes de quebra de estoque e persistencias de Dados
        End_Object
    End_Object

    // 4.3. Grid de Exibi‡Æo dos Dados Filtrados
    Object oGrid1 is a Grid
        Set Location to 19 5   
        Set Size to 189 413
        Set Line_Width to 5 0 
   
        // Configura‡Æo e Dimensionamento das Colunas
        Set Form_Width  0 to 50
        Set Header_Label  0 to "C¢d. énico"
        Set Form_Width  1 to 60
        Set Header_Label  1 to "C¢d. Local"
        Set Form_Width  2 to 70
        Set Header_Label  2 to "Qtd. Anterior"
        Set Form_Width  3 to 70
        Set Header_Label  3 to "Qtd. Atual"
        Set Form_Width  4 to 120
        Set Header_Label  4 to "Data de InclusÆo"
    
        // Rotina de carga dinƒmica aplicando a propriedade de filtro da View
        Procedure DoFillGrid
            Integer iItem
            String sFiltro
            Send Delete_Data
            
            // Captura o filtro configurado na propriedade da View ancestral
            Get psFiltroLocal of oMovimentacaoDeEstoque to sFiltro
            
            Open Movimentos
            Clear movimentos
            Find ge movimentos by Index.1
            
            While (Found)
                // FILTRO EM TEMPO DE EXECU€ÇO: S¢ insere na Grid se coincidir com o Local focado
                If (sFiltro = "" or sFiltro = Trim(movimentos.codlocal)) Begin
                    Send Add_Item msg_None movimentos.numunico
                    Send Add_Item msg_None movimentos.codlocal
                    Send Add_Item msg_None movimentos.quantanterior
                    Send Add_Item msg_None movimentos.quantatual
                    Send Add_Item msg_None movimentos.data_inclusao
                    
                    // Recupera o total de c‚lulas para setar como Shadow (Somente Leitura)
                    Get Item_Count to iItem
                    
                    Set Item_Shadow_State (iItem - 5) to True
                    Set Item_Shadow_State (iItem - 4) to True
                    Set Item_Shadow_State (iItem - 3) to True
                    Set Item_Shadow_State (iItem - 2) to True
                    Set Item_Shadow_State (iItem - 1) to True
                End
                
                Find gt movimentos by Index.1
            Loop
        End_Procedure
        
        // Evento p¢s-constru‡Æo que dispara o carregamento inicial da Grid
        Procedure End_Construct_object
            Forward Send End_Construct_Object
            Send DoFillGrid            
        End_Procedure
    End_Object

End_Object