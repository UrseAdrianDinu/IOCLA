
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<string.h>
typedef struct tree
{
    int value;
    struct tree *right;
    struct tree *left;
}tree;

tree* createnode()
{
    tree *newtree=(tree*)malloc(sizeof(tree));
    newtree->value=0;
    newtree->right=NULL;
    newtree->left=NULL;
    return newtree;
}

void createtree(char *token)
{
    char *p;
    p=strtok(token," ");
    while(p)
    {
        printf("%s\n",p);
        p=strtok( NULL," ");
    }
}
int main()
{
    char s[100]={"* -  5 6 7"};
    createtree(s);
    return 0;
}