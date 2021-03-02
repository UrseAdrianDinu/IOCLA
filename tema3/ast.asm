
section .data
    delim db " ", 0
    lungimeatoi:dd 0
    iocla_atoiflag:db 0
    check:dd 0
    checklungime:dd 0
    createnodecuvant:dd 0
    createnodelungime:dd 0
    esteinarbore:  dd 0
    node:dd 0
    

section .bss
    root resd 1
    
section .text
extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern strlen
extern malloc
extern strtok
extern strcpy
global create_tree
global iocla_atoi



iocla_atoi: 
    
    enter 0, 0
    ;Am salvat registrele
    push ebx
    push ecx
    push edx
    
    ;Initializare registre
    mov edx,[ebp+8]
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx ;iterator pentru string

    ;Flag indica daca un numar este negativ
    ;Initial este 0
    mov [iocla_atoiflag],byte 0

    ;Am comparat primul caracter din sir cu '-'
    ;pentru a verfica daca numarul este negativ
    cmp [edx],byte '-'
    jne numarpozitiv
    ;Daca numarul este negativ,atunci flag devine 1
    ;si am incrementat iteratorul pentru a sari primul caracter
    mov [iocla_atoiflag],byte 1
    inc ecx

    numarpozitiv:

    ;Cat timp caracterul de pe pozitia urmatoare
    ;nu este terminatorul de sir
    while:
    mov bl,[edx+ecx]
    sub bl,48

    ;Construiesc numarul
    imul eax,10
    add eax,ebx
    inc ecx

    ;Compar cu terminatorul de sir
    mov bl,[edx+ecx]
    cmp ebx,dword 0
    jne while

    ;Daca flagul este 1
    ;=> numar negativ
    cmp [iocla_atoiflag],byte 1
    je numarnegativ
    jmp end

    numarnegativ:
    ;Am imultit numarul cu -1
    imul eax,-1

    end:
    ;Am refacut registrele
    pop edx
    pop ecx
    pop ebx
    leave
    ret

create_tree:

    enter 0, 0

    ;Am salvat registrele
    push ebx
    push ecx
    push edx

    ;Am initializat registrele
    xor ecx,ecx
    xor edx,edx
    mov ebx,[ebp+8]
    
    ;Am extras primul cuvant
    push delim
    push ebx
    call strtok
    add esp,8

    ;Am creat nodul radacina, folosind primul cuvant extras
    push eax
    call createnode
    add esp,4
    mov [root],eax
    
    ;Cat timp mai exista cuvinte in string
    existacuvinte:

    ;Am extras urmatorul cuvant
    push delim
    push 0
    call strtok
    add esp,8
    
    ;Am verificat daca cuvantul curent este null
    test eax,eax
    je final

    ;"esteinarbore" este un flag care arata ca
    ;un nod se gaseste in arbore
    ;Initial este 0
    mov ecx,0
    mov [esteinarbore],ecx
    
    ;Am apelat functia build_tree, care are ca parametrii
    ;nodul radacina si cuvantul curent
    push eax
    push dword [root]
    call build_tree
    add esp,8

    jmp existacuvinte
    

    final:
    ;Am pus in eax nodul radacina
    mov eax,[root]

    ;Am refacut registrele
    pop edx
    pop ecx
    pop ebx

    leave
    ret

;Functie care primeste ca parametrii nodul root si un string
;si adauga in arbore nodul nou creat
build_tree:
    enter 0,0

    ;Am salvat registrele
    push ebx
    push ecx
    push edx

    ;Am verificat daca nodul curent este null
    cmp dword [ebp+8],0
    je build_treeend

    ;Am verificat daca nodul curent contine numar
    ;In acest caz, se iese din functie (numerele sunt mereu frunze)
    mov eax,[ebp+8]
    mov ebx,[eax]
    
    push ebx
    call checknumber
    add esp,4
    cmp eax,1
    je build_treeend
    
    ;Daca nodul curent nu este numar, am apelat build_tree
    ;pentru root->left,string
    mov eax,[ebp+8]
    mov edx,[ebp+12]
    mov eax,[eax+4]
    push edx
    push eax
    call build_tree
    add esp,8

    ;Daca nodul curent nu este numar, am apelat build_tree
    ;pentru root->right,string
    mov eax,[ebp+8]
    mov edx,[ebp+12]
    mov eax,[eax+8]
    push edx
    push eax
    call build_tree
    add esp,8

    ;Verific daca flagul 'esteinarbore' este 1
    ;In acest caz nodul este deja in arbore
    mov ebx,[esteinarbore]
    cmp ebx,1 
    je build_treeend

    ;Verfic daca nodul curent are fiu-stang
    mov edx,[ebp+8]
    mov edx,[edx+4]
    test edx,edx
    jne verificafiudrept

    ;Am creat un nod nou si l-am pus la copilul stang al nodului curent
    mov ebx,[ebp+12]
    push ebx
    call createnode
    add esp,4
    mov ebx,[ebp+8]
    mov [ebx+4],eax

    ;Am setat flagul la 1
    mov edx,1
    mov [esteinarbore],edx
    jmp build_treeend

    ;Am verificat daca nodul curent are fiu-drept
    verificafiudrept:
    mov edx,[ebp+8]
    mov edx,[edx+8]
    test edx,edx
    jne build_treeend

    ;Am creat un nod nou si l-am pus la copilul drept al nodului curent
    mov edx,[ebp+12]
    push edx
    call createnode
    add esp,4

    mov edx,[ebp+8]
    mov [edx+8],eax

    ;Am setat flagul la 1
    mov ecx,1
    mov [esteinarbore],ecx

    build_treeend:
    ;Am refacut registrele
    pop edx
    pop ecx
    pop ebx
    leave
    ret

;Functie care verifica daca un string este numar sau caracter
;Primeste ca parametru un string
checknumber:
    enter 0,0
    ;Am salvat registrele
    push ebx
    push ecx
    push edx

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    ;Am apelat strlen
    mov eax,[ebp+8]
    mov [check],eax
    push eax
    call strlen
    add esp,4
    
    ;Am comparat lungimea cu 1
    ;Daca este mai mare,atunci stringul este numar
    cmp eax,1
    jg adevarat

    ;Daca lungimea este 1,
    ;Am comparat caracterul cu '0'
    ;Daca este mai mare sau egal
    ;Atunci caracterul este numar
    ;Caracterele +-\* au codul ascii mai mic decat '0'
    mov edx,[check]
    cmp [edx],byte '0'
    jge adevarat

    ;Daca caracterul este mai mic, atunci el este caracter
    ;si am setat eax la 0
    mov eax,0
    jmp endchecknumber

    adevarat:
    ;Daca stringul este numar
    ;am setat eax la 1
    mov eax,1

    endchecknumber:
    ;Am refacut registrele
    pop edx
    pop ecx
    pop ebx
    leave
    ret

;Functie care creeaza un nod punand in data stringul dat ca parametru
createnode:
    enter 0,0
    ;Am salvat registrele
    push ebx
    push ecx
    push edx
    
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    
    ;Am salvat in createnodecuvant, stringul dat ca paramentru
    mov eax,[ebp+8]
    mov [createnodecuvant],eax

    ;Am apelat strlen si am salvat lungimea in [createnodelungime]
    push eax
    call strlen
    add esp,4
    mov [createnodelungime],eax

    ;Am alocat memorie pentru nod
    push 12
    call malloc
    add esp,4
    mov [node],eax

    ;Am alocat memorie pentru node->data
    mov eax,[createnodelungime]
    push eax
    call malloc
    add esp,4
    mov edx,[node]
    mov [edx],eax

    ;Am copiat la node->data,stringul dat ca parametru
    mov eax,[createnodecuvant]
    mov ebx,[edx]
    push eax
    push ebx
    call strcpy
    add esp,8

    ;Am setat node->right si node->left la NULL
    mov edx,[node]
    mov [edx+4],dword 0
    mov [edx+8],dword 0


    mov eax,edx

    ;Am refacut registrele
    pop edx
    pop ecx
    pop ebx
    leave
    ret
