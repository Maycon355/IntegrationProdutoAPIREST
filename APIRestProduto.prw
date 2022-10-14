#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*
Author: Maycon Motta
Data: 06/10/2022
Descritivo: Fonte Desenvolvido para integração de produtos via API REST.
Projeto: Miner

*/

WSRESTFUL MPRODUCT DESCRIPTION "Incluir Produto"

    WSMETHOD POST DESCRIPTION "Inclusão de Produto Simples" WSSYNTAX "/MPRODUCT/{id}"

END WSRESTFUL 


WSMETHOD POST WSSERVICE MPRODUCT

	Local cJSON         := Self:GetContent() // Pega a string do JSON
	Local oParseJSON    := Nil
	Local aProd := {}
	Local cJsonRet      := ""
	Local cArqLog       := ""
	Local cErro         := ""
	Local lRet          := .T.
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

    // –> Cria o diretório para salvar os arquivos de log

	If !ExistDir("\log_produto")
		MakeDir("\log_produto")
	EndIf

	// –> Deserializa a string JSON

	FWJsonDeserialize(cJson, @oParseJSON)
	SB1->( DbSetOrder(1))

	If !(SB1->(DbSeek( xFilial("SB1") + oParseJSON:PRODUTO:CODIGO)))
		
        aadd(aProd, {"B1_COD"    , oParseJSON:PRODUTO:CODIGO, NIL})
        aadd(aProd, {"B1_DESC"   , oParseJSON:PRODUTO:DESCRICAO, NIL})
        aadd(aProd, {"B1_TIPO"   , oParseJSON:PRODUTO:TIPO, NIL})
        aadd(aProd, {"B1_UM"     , oParseJSON:PRODUTO:UM, NIL})
        aadd(aProd, {"B1_LOCPAD" , oParseJSON:PRODUTO:LOCPAD, NIL})
		aadd(aProd, {"B1_PICM" , oParseJSON:PRODUTO:ICM, NIL})
		aadd(aProd, {"B1_IPI" , oParseJSON:PRODUTO:IPI, NIL})
		aadd(aProd, {"B1_LOCALIZ", oParseJSON:PRODUTO:LOCALIZ, NIL})
		aadd(aProd, {"B1_RASTRO", oParseJSON:PRODUTO:RASTRO, NIL})
		
        aProd := FWVetByDic(aProd, "SB1", .F., 1)
		MsExecAuto({|x, y| MATA010(x,y)}, aProd, 3)

		If lMsErroAuto
			cArqLog:= oParseJSON:PRODUTO:CODIGO + " – " +SubStr(Time(),1,5 ) + ".log"
			RollBackSX8()

			cErro:= MostraErro("\log_cli", cArqLog)
			cErro:= TrataErro(cErro) // –> Trata o erro para devolver para o client.

			SetRestFault(400, cErro)
			lRet:= .F.
		Else
			ConfirmSX8()
			cJSONRet := "Código Produto: " + oParseJSON:PRODUTO:CODIGO  +" Msg:" + "PRODUTO INCLUIDO COM SUCESSO! " + "}"
			::SetResponse( cJSONRet )
		EndIf
	Else
		SetRestFault(400, "PRODUTO já cadastrado: " + oParseJSON:PRODUTO:CODIGO)
		lRet:= .F.
	EndIf

Return lRet

return .T.


Static Function TrataErro(cErroAuto)

Local nLines   := MLCount(cErroAuto)
Local cNewErro := ""
Local nErr        := 0

For nErr := 1 To nLines
     cNewErro += AllTrim( MemoLine( cErroAuto, , nErr ) ) + " - "
Next nErr

Return(cNewErro)
