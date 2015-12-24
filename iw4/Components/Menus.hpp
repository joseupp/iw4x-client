#define MAX_SOURCEFILES	64

namespace Components
{
	class Menus : public Component
	{
	public:
		Menus();
		~Menus();
		const char* GetName() { return "Menus"; };

	private:
		static std::vector<Game::menuDef_t*> MenuList;
		static std::vector<Game::MenuList*> MenuListList;

		static Game::XAssetHeader MenuFileLoad(Game::XAssetType type, const char* filename);
		static Game::MenuList* LoadMenuList(Game::MenuList* menuList);
		static std::vector<Game::menuDef_t*> LoadMenu(Game::menuDef_t* menudef);

		static Game::script_t* LoadMenuScript(const char* name, std::string buffer);
		static int LoadMenuSource(const char* name, std::string buffer);

		static int ReserveSourceHandle();
		static bool IsValidSourceHandle(int handle);

		static int ReadToken(int handle, Game::pc_token_t *pc_token);

		static Game::menuDef_t* ParseMenu(int handle);

		static void FreeMenuSource(int handle);

		static void FreeMenuList(Game::MenuList* menuList);
		static void FreeMenu(Game::menuDef_t* menudef);

		static void RemoveMenu(Game::menuDef_t* menudef);
		static void RemoveMenuList(Game::MenuList* menuList);

		static void FreeEverything();

		// Ugly!
		static int KeywordHash(char* key);
	};
}
