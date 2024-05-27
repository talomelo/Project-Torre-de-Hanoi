section .data
    ; Mensagem exibida para solicitar a entrada do usuário
    menu db 'Digite a quantidade de discos:', 0xa
    len_menu equ $-menu

    ; Mensagem para imprimir a movimentação dos discos
    msg db "ORIGEM: ", ' ', " => DESTINO: ", ' ', 0xa
    len_msg equ $-msg

    ; Mensagem de conclusão
    msg_concluido db 'Concluído!', 0xa
    len_msg_concluido equ $-msg_concluido

    ; Constantes para chamadas de sistema
    SYS_WRITE equ 4
    SYS_READ equ 3
    SYS_EXIT equ 1
    ; Descritores de arquivo padrão
    STDIN equ 0
    STDOUT equ 1

section .bss
    ; Buffer para armazenar a entrada do usuário
    disk resb 5

section .text
    global _start

_start:
    ; Exibindo o menu para o usuário
    mov edx, len_menu;Usado para contagem
    mov ecx, menu;Armazenar argumentos para chamadas de sistema
    mov ebx, STDOUT;Armazenar argumentos para chamadas de sistema
    mov eax, SYS_WRITE;Armazenar valores de retorno de função
    int 0x80

    ; Lendo a entrada do usuário
    mov ecx, disk            ; Endereço para armazenar a entrada
    mov ebx, STDIN           ; Descritor de arquivo de entrada (teclado)
    mov eax, SYS_READ        ; Chamada de sistema para ler
    mov edx, 5               ; Lendo até 5 caracteres
    int 0x80

    ; Convertendo a entrada de string para número
    mov edx, disk
    call convertStringToInt

    ; Configurando os parâmetros para a função Hanoi
    push dword 2
    push dword 3
    push dword 1
    push eax

    ; Chamando a função Hanoi
    call funcaoHanoi

    ; Exibindo a mensagem de conclusão
    mov edx, len_msg_concluido
    mov ecx, msg_concluido
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    ; Saindo do programa
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

; Função para converter uma string em um número inteiro
convertStringToInt:
    xor eax, eax       ; Zerando o registrador eax
    mov ebx, 10        ; Base decimal para conversão

    .convert_loop:
        movzx ecx, byte [edx]  ; Carrega o próximo caractere da string
        cmp ecx, 0            ; Verifica se chegou ao final da string
        je .convert_done     ; Se sim, termina a conversão
        cmp ecx, '0'           ; Verifica se é um dígito válido
        jb .convert_done       ; Se não for, sai do loop
        cmp ecx, '9'
        ja .convert_done

        sub ecx, '0'           ; Converte o caractere em seu valor numérico
        imul eax, ebx          ; Multiplica o número existente por 10
        add eax, ecx           ; Adiciona o valor do dígito atual
        inc edx                ; Avança para o próximo caractere
        jmp .convert_loop      ; Repete o processo para o próximo caractere

    .convert_done:
        ret

; Função para resolver a Torre de Hanói
funcaoHanoi:
    push ebp
    mov ebp, esp

    ; Parâmetro n (quantidade de discos)
    mov eax, [ebp+8]
    cmp eax, 0
    jle .funcaoHanoi_end

    ; Primeiro passo: mover n-1 discos de origem para auxiliar
    dec eax
    push dword [ebp+16]    ; destino
    push dword [ebp+20]    ; auxiliar
    push dword [ebp+12]    ; origem
    push eax               ; n-1
    call funcaoHanoi
    add esp, 16

    ; Segundo passo: mover o disco de origem para destino
    push dword [ebp+16]    ; destino
    push dword [ebp+12]    ; origem
    push dword [ebp+8]     ; disco
    call printMove
    add esp, 12

    ; Terceiro passo: mover n-1 discos de auxiliar para destino
    push dword [ebp+12]    ; origem
    push dword [ebp+16]    ; destino
    push dword [ebp+20]    ; auxiliar
    mov eax, [ebp+8]
    dec eax
    push eax               ; n-1
    call funcaoHanoi
    add esp, 16

.funcaoHanoi_end:
    mov esp, ebp
    pop ebp
    ret

; Função para imprimir uma jogada da Torre de Hanói
printMove:
    push ebp
    mov ebp, esp

    ; Preparando a mensagem
    mov eax, [ebp+12]
    add al, 'A' - 1
    mov [msg+8], al

    mov eax, [ebp+16]
    add al, 'A' - 1
    mov [msg+21], al

    ; Escrevendo a mensagem
    mov edx, len_msg
    mov ecx, msg
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    ; Restaurando a pilha e retornando
    pop ebp
    ret
