# Dashboard de Performance Logística - Power BI

> Projeto de Portfólio | Análise de dados com Power BI, SQL e modelagem DAX em **cenário simulado**
>
> ## Descrição
>
> Este projeto demonstra a criação de um dashboard interativo de performance logística utilizando Power BI, integrado com **dataset fictício** de pedidos, entregas e estoque. O objetivo é analisar métricas operacionais chave para suportar decisões de negócios.
>
> ### Stack Tecnológico
>
> - **SQL**: Criação de tabelas, consultas KPI e análises operacionais
> - - **Power BI**: Visualização de dados e modelagem
>   - - **DAX**: Cálculos avançados e medidas
>     - - **Excel**: Suporte a dados tabulares
>      
>       - ## Processo Analítico
>      
>       - ### 1. Entendimento do Problema
>       - - Identificação de KPIs de logística (taxa de entrega no prazo, tempo médio de entrega)
>         - - Definição de dimensões de análise (região, categoria de produto, status de entrega)
> - Escopo: cenário simulado para fins de portfólio
>
> - ### 2. Preparação dos Dados
> - - **Criação de schema** (`sql/create_tables.sql`): 5 tabelas relacionais
>   -   - `pedidos`: Informações de vendas
>       -   - `clientes`: Dados demográficos
>           -   - `entregas`: Rastreamento de logística
>               -   - `estoque`: Disponibilidade de produtos
>                   -   - `produtos`: Catlogo
>                       - - **Limpeza e validação**: Constraints e foreign keys
>                        
>                         - ### 3. Modelagem
>                         - - **Dimensões**: Cliente, Produto, Data
>                           - - **Fatos**: Pedidos, Entregas, Estoque
>                             - - **Relações**: Star schema normalizado
>                              
>                               - ### 4. DAX (Data Analysis Expressions)
>                               - - **Medidas calculadas**:
>                                 -   - Taxa de Entrega no Prazo (%)
>                                     -   - Tempo Médio de Entrega (dias)
>                                         -   - Receita Total por Região
>                                             -   - Disponibilidade de Estoque
>                                                 - - **Colunas derivadas**: Categorizações, buckets de tempo
>                                                  
>                                                   - ### 5. Dashboard
>                                                   - - **Páginas**:
>                                                     -   1. Visão Executiva: KPIs principais e tendências
>                                                         2.   2. Performance de Entrega: Eficiência por região
>                                                              3.   3. Análise de Estoque: Disponibilidade e rotatividade
>                                                                   4.   4. Análise de Vendas: Receita, ticket médio, clientes top
>                                                                        5. - **Filtros**: Região, período, categoria
>                                                                           - - **Visualizações**: KPIs, gráficos, tabelas detalhadas
>                                                                            
>                                                                             - ### 6. Insights
>                                                                             - - Identificação de regiões com melhor desempenho de entrega
>                                                                               - - Produtos com maior/menor disponibilidade
>                                                                                 - - Tendências de vendas e sazonalidade
>                                                                                   - - Clientes estratgicos com maior valor
>                                                                                    
>                                                                                     - ## Arquivos do Projeto
>                                                                                    
>                                                                                     - ```
>                                                                                       dashboard-performance-logistica-powerbi/
>                                                                                       ├── sql/
>                                                                                       │   ├── create_tables.sql           # Schema e definição de tabelas
>                                                                                       │   ├── consultas_kpis.sql          # Queries de KPIs principais
>                                                                                       │   └── analises_operacionais.sql  # Análises avançadas
>                                                                                       ├── README.md                   # Este arquivo
>                                                                                       └── Dashboard.pbix             # Arquivo Power BI (em desenvolvimento)
>                                                                                       ```
>
> ## Como Usar
>
> 1. **Importar dados SQL**: Execute os scripts em `sql/` para criar as tabelas e popular com dados simulados
> 2. 2. **Conectar Power BI**: Use os dados da base de dados em Power BI
>    3. 3. **Atualizar Dashboard**: Carregue o arquivo `.pbix` e atualize as conexões
>       4. 4. **Explorar Insights**: Interaja com os filtros e visualizações
>         
>          5. ## Ferramentas e Versões
>         
>          6. - **SQL Server**: 2019+
>             - - **Power BI Desktop**: Versão mais recente
>               - - **DAX Studio**: Para otimização (opcional)
>                
>                 - ## Notas Importantes
>                
>                 - - ⚠️ **Dataset Fictício**: Todos os dados são simulados para fins educacionais
>                   - - 🌟 **Projeto de Portfólio**: Desenvolvido como exemplo profissional
>                     - - 🔄 **Cenário Simulado**: Não reflete dados reais de nenhuma organização
>                      
>                       - ## Contato
>                      
>                       - **José Pérez** - Analista de Dados Jr
>                       - Curitiba, PR | Brasil
>                       - LinkedIn: [Profile](https://www.linkedin.com/in/jose-ronaldo-perez-gomez)
> GitHub: [@jrperezgomez](https://github.com/jrperezgomez)
>
> ---
>
> *Projeto desenvolvido em julho de 2026 para demonstração de habilidades em análise de dados.*
