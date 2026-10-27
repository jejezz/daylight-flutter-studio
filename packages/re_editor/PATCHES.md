# re_editor 0.10.0 복사본의 고친 점

- 글꼴 기능(OpenType feature)을 줄 수 있게 했다. 원본의 `CodeEditorStyle`에는 `fontFeatures`가 없어서 합자(ligature)를 끌 수 없었다.
  - `lib/src/code_editor.dart`: `CodeEditorStyle.fontFeatures`를 더하고, 편집기 본문 글꼴(`baseStyle`)에 넘긴다.
  - 구문 강조 조각은 이 글꼴을 이어받는다(엔진이 안 정한 값은 부모 것을 쓴다).
- 원본이 고치면 되돌린다.
